{self, ...}: {
  # The homelab dashboard compares this against main to show deploy drift.
  system.configurationRevision = self.rev or self.dirtyRev or null;
}
