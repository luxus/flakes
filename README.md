# NixOS Configuration Flake

This repository contains NixOS configurations managed as a Nix flake.

## Machines

### vanessa
- **Architecture**: x86_64-linux
- **Hardware**: Intel CPU with NVIDIA GPU
- **Features**: 
  - Disko for disk management with btrfs subvolumes
  - NVIDIA drivers with hardware acceleration
  - Determinate Nix enhancements
  - Hardware detection via nixos-facter-modules
  - Zsh shell configuration

## Testing

The configuration is automatically tested using GitHub Actions on every push and pull request.

### Local Testing

You can test the configuration locally:

```bash
# Check flake validity
nix flake check

# Build the vanessa configuration
nix build .#nixosConfigurations.vanessa.config.system.build.toplevel

# Build packages
nix build .#packages.x86_64-linux.default
nix build .#packages.x86_64-linux.nix-maid

# Test disko configuration
nix build .#nixosConfigurations.vanessa.config.system.build.diskoScript
```

### CI/CD Pipeline

The GitHub Actions workflow includes:

1. **Flake validation**: Ensures the flake structure is correct
2. **Configuration building**: Builds the complete NixOS system
3. **Package building**: Tests individual packages
4. **Disko validation**: Validates disk configuration
5. **Security checks**: Basic security validation
6. **Formatting checks**: Code style validation

## Deployment

To deploy to the vanessa machine:

```bash
# Build and switch (on the target machine)
sudo nixos-rebuild switch --flake .#vanessa

# Or build remotely and deploy
nixos-rebuild switch --flake .#vanessa --target-host root@vanessa
```

## Development

### Adding New Machines

1. Create a new directory under `hosts/`
2. Add `configuration.nix` and any machine-specific modules
3. Add the machine to `flake.nix` in `nixosConfigurations`
4. Update this README

### Modifying Existing Configurations

1. Make changes to the relevant configuration files
2. Test locally with `nix flake check`
3. Build the configuration to ensure it works
4. Commit and push - CI will validate the changes

## Features

- **Flake-based configuration** for reproducible builds
- **Disko integration** for declarative disk management
- **NVIDIA support** with hardware acceleration
- **Determinate Nix** for enhanced performance
- **Hardware detection** via facter
- **Automated testing** via GitHub Actions
- **Zsh configuration** with enhancements

## Dependencies

Key flake inputs:
- `nixpkgs`: NixOS packages
- `disko`: Declarative disk partitioning
- `nixos-facter-modules`: Hardware detection
- `nix-maid`: Nix maintenance tools
