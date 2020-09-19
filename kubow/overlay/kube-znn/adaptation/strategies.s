module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };
import lib "tactics.s";

define boolean highMode = M.kubeZnnD.replicasHigh >= M.kubeZnnD.desiredReplicas;


define boolean sloRed = M.kubeZnnS.slo <= 0.95;
define boolean sloGreen = M.kubeZnnS.slo >= 0.99;


define boolean canAddReplica = M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;

/*
 * ----
 */
strategy ImproveSlo [ sloRed ] {
  t0: (sloRed && canAddReplica) -> addReplica() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (sloRed && !canAddReplica) -> lowerFidelity() @[20000 /*ms*/] {
    t1a: (success) -> done;
  }
  t2: (default) -> TNULL;
}

/*
 * ----
 */
strategy ReduceCost [ sloGreen && highMode ] {
  t0: (sloGreen && canRemoveReplica && highMode) -> removeReplica() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}

/*
 * ----
 */
strategy ImproveFidelity [ sloGreen && !highMode ] {
  t0: (sloGreen && !highMode) -> raiseFidelity() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}
