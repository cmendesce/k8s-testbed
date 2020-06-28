module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };
import lib "tactics.s";

define boolean lowMode = M.kubeZnnD.replicasLow == M.kubeZnnD.desiredReplicas;
define boolean highMode = M.kubeZnnD.replicasHigh == M.kubeZnnD.desiredReplicas;

define boolean sloRed = M.kubeZnnS.slo < M.kubeZnnS.expectedSlo;
define boolean sloGreen = M.kubeZnnS.slo >= M.kubeZnnS.desiredSlo;

define boolean canAddReplica = M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;

/*
 * ----
 */
strategy ImproveSlo [ sloRed ] {
  t0: (sloRed && canAddReplica) -> addReplicas(1) @[20000 /*ms*/] {
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
  t0: (sloGreen && canRemoveReplica && highMode) -> removeReplicas(1) @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}

/*
 * ----
 */
strategy ImproveFidelity [ sloGreen && lowMode ] {
  t0: (sloGreen && lowMode) -> raiseFidelity() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}
