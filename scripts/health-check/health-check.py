#!/usr/bin/env python3
"""Check that the Deployments in one or more namespaces are healthy.

Connects to the Kubernetes API with a ServiceAccount token and, for each namespace:

1. Access: asks the API server whether the token may get, list and watch each
   required resource, and prints each decision with the reason the API server
   gives. This is the same check kubectl auth can-i makes.
2. Resources: lists the namespace's pods, services and deployments, and prints
   what the API server returns.
3. Health: reports each Deployment as OK or FAIL. A Deployment is OK when
   its rollout is complete, as the Kubernetes docs define it:
     - all replicas are updated to the latest version
     - all replicas are available
     - no old replicas are running

Every check runs, and each failure is reported.
Exits 0 if every check passes, 1 if any fails, 2 on a usage error.

Environment variables:
  K8S_API_SERVER  API server URL, e.g. https://127.0.0.1:45551
  K8S_CA_CERT     Path to the cluster's CA certificate, used to verify the API server
  K8S_TOKEN       ServiceAccount token, from kubectl create token
"""

import argparse
import os
import sys

from kubernetes import client
from kubernetes.client.rest import ApiException

REQUIRED_ENV = ("K8S_API_SERVER", "K8S_CA_CERT", "K8S_TOKEN")
TIMEOUT_SECONDS = 10

# What the token must be allowed to do in every namespace it checks. "" is the core API group.
REQUIRED_RESOURCES = (("", "pods"), ("", "services"), ("", "events"), ("apps", "deployments"))
REQUIRED_VERBS = ("get", "list", "watch")

API_ERROR_HINTS = {
    401: "the token is invalid or expired; create a new one",
    403: "the ServiceAccount isn't allowed to read this namespace; check its RoleBinding",
}


def api_client(server: str, ca_cert: str, token: str) -> client.ApiClient:
    configuration = client.Configuration()
    configuration.host = server
    configuration.ssl_ca_cert = ca_cert  # verify_ssl is on by default; this is what it verifies against
    configuration.api_key = {"authorization": f"Bearer {token}"}
    return client.ApiClient(configuration)


def api_error(error: ApiException) -> str:
    hint = API_ERROR_HINTS.get(error.status, "")
    return f"API error {error.status} {error.reason}" + (f": {hint}" if hint else "")


def identity(authn: client.AuthenticationV1Api) -> str:
    """Return the username the API server authenticated the token as."""
    review = authn.create_self_subject_review(client.V1SelfSubjectReview(), _request_timeout=TIMEOUT_SECONDS)
    return review.status.user_info.username


def check_access(authz: client.AuthorizationV1Api, namespace: str) -> bool:
    """Print the API server's decision for each required resource and verb. Return True if all are allowed."""
    print("  Access")
    allowed_all = True

    for group, resource in REQUIRED_RESOURCES:
        for verb in REQUIRED_VERBS:
            review = client.V1SelfSubjectAccessReview(
                spec=client.V1SelfSubjectAccessReviewSpec(
                    resource_attributes=client.V1ResourceAttributes(
                        group=group, resource=resource, verb=verb, namespace=namespace
                    )
                )
            )
            status = authz.create_self_subject_access_review(review, _request_timeout=TIMEOUT_SECONDS).status
            allowed_all = allowed_all and status.allowed
            name = f"{resource}.{group}" if group else resource
            reason = status.reason or "no rule allows it"
            print(f"    {'ALLOW' if status.allowed else 'DENY '}  {verb:<5}  {name:<16}  {reason}")

    return allowed_all


def print_table(headers: list[str], rows: list[list[str]]) -> None:
    widths = [max(len(row[column]) for row in [headers, *rows]) for column in range(len(headers))]
    for row in [headers, *rows]:
        print("      " + "  ".join(cell.ljust(width) for cell, width in zip(row, widths)).rstrip())


def pod_row(pod: client.V1Pod) -> list[str]:
    statuses = pod.status.container_statuses or []
    ready = sum(1 for container in statuses if container.ready)
    # Like kubectl, show why a container is waiting (e.g. CrashLoopBackOff) instead of the pod phase.
    waiting = next((container.state.waiting.reason for container in statuses if container.state.waiting), None)
    restarts = sum(container.restart_count for container in statuses)
    return [pod.metadata.name, f"{ready}/{len(pod.spec.containers)}", waiting or pod.status.phase, str(restarts)]


def service_row(service: client.V1Service) -> list[str]:
    ports = ",".join(
        f"{port.port}:{port.node_port}/{port.protocol}" if port.node_port else f"{port.port}/{port.protocol}"
        for port in service.spec.ports or []
    )
    return [service.metadata.name, service.spec.type, service.spec.cluster_ip, ports]


def deployment_row(deployment: client.V1Deployment) -> list[str]:
    status = deployment.status
    return [
        deployment.metadata.name,
        f"{status.ready_replicas or 0}/{deployment.spec.replicas}",
        str(status.updated_replicas or 0),
        str(status.available_replicas or 0),
    ]


def list_resources(apps: client.AppsV1Api, core: client.CoreV1Api, namespace: str) -> bool:
    """List the namespace's pods, services and deployments and print what the API server returns.

    Return True if every list call was allowed.
    """
    print("  Resources")
    # (resource, API call, column headers, function that turns one returned object into a row)
    listings = (
        ("pods", lambda: core.list_namespaced_pod(namespace, _request_timeout=TIMEOUT_SECONDS),
         ["NAME", "READY", "STATUS", "RESTARTS"], pod_row),
        ("services", lambda: core.list_namespaced_service(namespace, _request_timeout=TIMEOUT_SECONDS),
         ["NAME", "TYPE", "CLUSTER-IP", "PORT(S)"], service_row),
        ("deployments", lambda: apps.list_namespaced_deployment(namespace, _request_timeout=TIMEOUT_SECONDS),
         ["NAME", "READY", "UP-TO-DATE", "AVAILABLE"], deployment_row),
    )
    allowed_all = True

    for resource, list_call, headers, to_row in listings:
        try:
            items = list_call().items
        except ApiException as error:
            print(f"    FAIL   list {resource}: {api_error(error)}")
            allowed_all = False
            continue
        print(f"    OK     list {resource}: allowed, {len(items)} returned")
        if items:
            print_table(headers, [to_row(item) for item in items])

    return allowed_all


def deployment_problems(deployment: client.V1Deployment) -> list[str]:
    """Return why the Deployment's rollout isn't complete. An empty list means it is."""
    desired = deployment.spec.replicas
    status = deployment.status
    # The API leaves out counts that are 0, so the client returns None for them.
    total = status.replicas or 0
    updated = status.updated_replicas or 0
    available = status.available_replicas or 0
    problems = []

    # Until the controller has seen the latest spec, the counts below describe an older version.
    if (status.observed_generation or 0) < deployment.metadata.generation:
        problems.append("latest change not yet processed")
    if updated < desired:
        problems.append(f"{updated}/{desired} updated")
    if available < desired:
        problems.append(f"{available}/{desired} available")
    if total > updated:
        problems.append(f"{total - updated} old replica(s) still running")
    for condition in status.conditions or []:
        if condition.type == "Progressing" and condition.reason == "ProgressDeadlineExceeded":
            problems.append("rollout failed: progress deadline exceeded")

    return problems


def pod_problems(core: client.CoreV1Api, deployment: client.V1Deployment) -> list[str]:
    """Return a line for each of the Deployment's pods that isn't ready, with the reason."""
    # Only match_labels is handled; the web-app module doesn't use match_expressions.
    selector = ",".join(f"{key}={value}" for key, value in deployment.spec.selector.match_labels.items())
    pods = core.list_namespaced_pod(
        deployment.metadata.namespace, label_selector=selector, _request_timeout=TIMEOUT_SECONDS
    )
    lines = []

    for pod in pods.items:
        if not pod.status.container_statuses:
            lines.append(f"{pod.metadata.name}: {pod.status.phase}")
            continue
        for container in pod.status.container_statuses:
            if not container.ready:
                waiting = container.state.waiting
                reason = waiting.reason if waiting else "not ready"
                lines.append(f"{pod.metadata.name}: {container.name} {reason}, {container.restart_count} restarts")

    return lines


def check_deployments(apps: client.AppsV1Api, core: client.CoreV1Api, namespace: str) -> bool:
    """Print the health of each Deployment in the namespace. Return True if all are OK."""
    print("  Health")
    try:
        deployments = apps.list_namespaced_deployment(namespace, _request_timeout=TIMEOUT_SECONDS).items
        if not deployments:
            print("    FAIL   no Deployments found")
            return False

        healthy = True
        for deployment in deployments:
            name = deployment.metadata.name
            problems = deployment_problems(deployment)
            if problems:
                healthy = False
                print(f"    FAIL   {name}: {', '.join(problems)}")
                for line in pod_problems(core, deployment):
                    print(f"           {line}")
            else:
                print(f"    OK     {name}: {deployment.status.available_replicas}/{deployment.spec.replicas} available")
        return healthy

    except ApiException as error:
        print(f"    FAIL   {api_error(error)}")
        return False


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("namespaces", nargs="+", metavar="namespace", help="namespace to check")
    args = parser.parse_args()

    missing = [name for name in REQUIRED_ENV if not os.environ.get(name)]
    if missing:
        parser.error(f"environment variable(s) not set: {', '.join(missing)}")

    with api_client(os.environ["K8S_API_SERVER"], os.environ["K8S_CA_CERT"], os.environ["K8S_TOKEN"]) as api:
        authz = client.AuthorizationV1Api(api)
        apps = client.AppsV1Api(api)
        core = client.CoreV1Api(api)

        try:
            print(f"Authenticated as {identity(client.AuthenticationV1Api(api))}")
        except ApiException as error:
            # Without a working token every other check would fail the same way.
            print(f"FAIL   {api_error(error)}")
            return 1

        results = []
        for namespace in args.namespaces:
            print(f"\n{namespace}")
            results.append(check_access(authz, namespace))
            results.append(list_resources(apps, core, namespace))
            results.append(check_deployments(apps, core, namespace))

    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
