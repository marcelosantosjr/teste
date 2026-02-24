# Infra DevOps para Azure (Terraform + GitHub Actions + Ansible)

Este repositório provisiona **uma VM Ubuntu no Azure** com boas práticas de IaC e, em seguida, configura a máquina com **Ansible** para subir:

- n8n
- Evolution API
- Chatwoot
- Portainer

## Arquitetura

1. **Terraform** cria:
   - Resource Group
   - VNet/Subnet
   - NSG + regras de entrada
   - Public IP + NIC
   - VM Linux
2. **GitHub Actions** executa o ciclo IaC (`fmt`, `validate`, `plan`, `apply`).
3. A VM já sobe com Docker/Compose habilitados via cloud-init e também com o Portainer iniciado no boot; após `apply` o pipeline dispara **Ansible** para publicar os demais serviços via Docker Compose.

## Pré-requisitos

- Conta Azure
- Service Principal com permissões para criar recursos
- Repositório GitHub com Actions habilitado
- Segredos configurados no GitHub:
  - `AZURE_CREDENTIALS` (JSON do service principal)
  - `TF_VAR_admin_ssh_public_key`
  - `SSH_PRIVATE_KEY`

## Uso local (opcional)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Execução via GitHub Actions

Workflow: `.github/workflows/infra.yml`

- Rode manualmente via `workflow_dispatch`.
- Defina `apply=true` para aplicar mudanças.

## Segurança e boas práticas

- Evite commitar segredos.
- Use backend remoto do Terraform (ver `terraform/backend.tf.example`).
- Restringa portas no NSG para IPs confiáveis.
- Use domínio + TLS (ex.: Traefik/Nginx + Let's Encrypt) para produção.

## Observações sobre os serviços

- `chatwoot` depende de `postgres` e `redis`.
- `n8n` e `evolution-api` foram definidos via Docker Compose (Ansible).
- `portainer` é instalado e iniciado no bootstrap da VM via cloud-init.
- Ajuste variáveis em `ansible/group_vars/all/main.yml` conforme necessidade.


## Troubleshooting (erro de `admin_ssh_key.public_key` vazio)

Se o workflow falhar com:

```text
expected "admin_ssh_key.0.public_key" to not be an empty string or whitespace
```

isso indica que o secret `TF_VAR_admin_ssh_public_key` está vazio/inválido.

1. Gere ou use uma chave pública existente:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa.pub
```

2. No GitHub, configure **Settings > Secrets and variables > Actions**:
   - `TF_VAR_admin_ssh_public_key` = conteúdo completo da chave pública (`ssh-rsa ...` ou `ssh-ed25519 ...`).
3. Rode o workflow novamente.
