# Notation Plugin Test - Container Image Signing

This repository contains a GitHub workflow that demonstrates how to sign container images using Notation with Azure Key Vault integration.

## Prerequisites

### 1. Azure Setup

You need to set up the following in Azure:

1. **Azure Container Registry (ACR)** - to store your container images
2. **Azure Key Vault** - to store signing keys
3. **Azure App Registration** - for federated credentials
4. **Service Principal** - with appropriate permissions

### 2. Azure App Registration for Federated Credentials

1. Create an App Registration in Azure AD
2. Configure federated credentials for GitHub Actions:
   - Issuer: `https://token.actions.githubusercontent.com`
   - Subject identifier: `repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:ref:refs/heads/main`
   - Audience: `api://AzureADTokenExchange`

### 3. Required GitHub Secrets

Add the following secrets to your GitHub repository:

```
AZURE_CLIENT_ID          # Application (client) ID from App Registration
AZURE_TENANT_ID          # Directory (tenant) ID from App Registration  
AZURE_SUBSCRIPTION_ID    # Your Azure subscription ID
AZURE_KEY_VAULT_KEY_ID   # Key Vault key identifier (e.g., https://your-keyvault.vault.azure.net/keys/your-key/version)
```

### 4. Azure Permissions

Ensure your App Registration has the following permissions:

- **ACR Push/Pull**: `AcrPush` and `AcrPull` roles on the container registry
- **Key Vault Access**: `Key Vault Crypto User` role on the key vault
- **Subscription Access**: `Contributor` or appropriate role on the subscription

## Workflow Configuration

### Environment Variables

Update the following environment variables in `.github/workflows/sign-image.yml`:

```yaml
env:
  REGISTRY: your-registry.azurecr.io    # Your ACR registry URL
  IMAGE_NAME: your-image-name           # Your container image name
```

### Notation Configuration

The workflow uses:
- **Notation CLI**: Latest stable version
- **Azure Key Vault Plugin**: For signing with Azure Key Vault keys
- **COSE signature format**: Industry standard format

## Usage

1. **Push to main branch** or **create a pull request** to trigger the workflow
2. The workflow will:
   - Build and push your container image
   - Sign the image using Notation with Azure Key Vault
   - Verify the signature
   - Output the signed image reference

## Docker Image Requirements

Ensure you have a `Dockerfile` in your repository root. Example:

```dockerfile
FROM alpine:latest
RUN echo "Hello, Notation!" > /hello.txt
CMD ["cat", "/hello.txt"]
```

## Verification

After the workflow completes, you can verify the signature locally:

```bash
# Install notation CLI
curl -Lo notation.tar.gz https://github.com/notaryproject/notation/releases/download/v1.0.0/notation_1.0.0_linux_amd64.tar.gz
tar xzf notation.tar.gz
sudo mv notation /usr/local/bin/

# Verify the signed image
notation verify your-registry.azurecr.io/your-image-name:TAG
```

## Troubleshooting

### Common Issues

1. **Authentication Failures**
   - Verify federated credential configuration
   - Check App Registration permissions
   - Ensure secrets are correctly set

2. **Key Vault Access**
   - Verify Key Vault permissions
   - Check key ID format and existence
   - Ensure key vault allows public access or configure network rules

3. **Registry Access**
   - Verify ACR permissions
   - Check registry URL format
   - Ensure ACR allows public access or configure authentication

### Debug Mode

To enable debug logging, add this to your workflow:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  NOTATION_EXPERIMENTAL: 1
```

## Security Considerations

- Use federated credentials instead of service principal secrets
- Rotate keys regularly in Azure Key Vault
- Use least privilege principles for permissions
- Monitor signing activities through Azure logs
- Consider using private endpoints for enhanced security

## References

- [Notation Documentation](https://notaryproject.dev/)
- [Azure Key Vault Plugin](https://github.com/Azure/notation-azure-kv)
- [GitHub OIDC with Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
