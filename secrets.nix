let
  # User SSH keys (for editing secrets)
  justin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1yxPYp+r0pI+lZCpsq4C5eDIrTnfkR9NqLgH3fVFlG";

  # Host SSH keys (for decrypting at boot)
  spinel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJygymGxYYw1Fongu9oc75bzLrlEQHIH51BW2xuFgvgd";
in
{
  "hosts/spinel/password.age".publicKeys = [
    justin
    spinel
  ];
}
