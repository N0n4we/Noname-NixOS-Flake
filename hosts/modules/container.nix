{ pkgs, ... }:
{
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    ctop
    minikube
    kubectl
    kubernetes-helm
  ];
}
