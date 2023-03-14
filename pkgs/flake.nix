{
  outputs = { self }: {
    overlay = final: prev: {
      oktaws = prev.callPackage ./oktaws/default.nix { };
    };
  };
}