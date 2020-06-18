module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };

define boolean lowMode = M.kubeZnnD.replicasLow == M.kubeZnnD.desiredReplicas;
define boolean highMode = M.kubeZnnD.replicasHigh == M.kubeZnnD.desiredReplicas;

define string highModeImage = "cmendes/znn:600k";
define string lowModeImage = "cmendes/znn:100k";

tactic addReplicas(int count) {
  int replicas = M.kubeZnnD.desiredReplicas;
  condition {
    M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
  }
  action {
    M.scaleUp(M.kubeZnnD, count);
  }
  effect @[5000] {
    replicas' + count == M.kubeZnnD.desiredReplicas;
  }
}

tactic removeReplicas(int count) {
  int replicas = M.kubeZnnD.desiredReplicas;
  condition {
    M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;
  }
  action {
    M.scaleDown(M.kubeZnnD, count);
  }
  effect @[5000] {
    replicas' - count == M.kubeZnnD.desiredReplicas;
  }
}

tactic lowerFidelity() {
  condition {
    highMode;
  }
  action {
    M.rollOut(M.kubeZnnD, "znn", lowModeImage);
  }
  effect @[10000] {
    lowMode;
  }
}

tactic raiseFidelity() {
  condition {
    lowMode;
  }
  action {
    M.rollOut(M.kubeZnnD, "znn", highModeImage);
  }
  effect @[10000] {
    highMode;
  }
}

