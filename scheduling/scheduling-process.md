# Process Steps
Every process step have pre, main and post steps.

## Scheduling Queue
- We can set priority in the spec of the object with the `propertyClassName` property.
- Priority is a number between 0 and 1000000000.
- The default priority is 0.
- The higher the number, the higher the priority.
- The priority is used to determine the order in which pods are scheduled.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false # optional. This means that the priority class is not the default priority class.
description: "This priority class should be used for XYZ service pods only."
```

- Scheduler will use the priority to determine the order in which pods are scheduled.


## Filter
- The scheduler filters out nodes that do not meet the requirements of the pod.
- Scheduler looks;
  - CPU and memory requirements
  - Node selectors
  - Taints and tolerations
  - Node affinity and anti-affinity
  - ....

### Unschedulable Nodes
- Nodes that are not schedulable are not considered for scheduling.
- When this value is set to true, the scheduler will not consider nodes that are not schedulable.
- We can see it with `kubectl describe node <node-name>` command.


## Scoring
- The scheduler assigns a score to each node that passed the filtering.


## Binding
- The scheduler binds the pod to the node with the highest score.