# "Toolbox" image with every tool this project needs, so it runs the same on
# Windows, macOS or Linux with nothing installed except Docker.
FROM python:3.12-slim

ARG TERRAFORM_VERSION=1.17.1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl unzip openssh-client make git ca-certificates less groff \
 && rm -rf /var/lib/apt/lists/*

# Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/tf.zip \
 && unzip -q /tmp/tf.zip -d /usr/local/bin \
 && rm /tmp/tf.zip

# AWS CLI v2
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli.zip \
 && unzip -q /tmp/awscli.zip -d /tmp \
 && /tmp/aws/install \
 && rm -rf /tmp/aws /tmp/awscli.zip

# Ansible
RUN pip install --no-cache-dir "ansible-core>=2.16,<2.19" ansible-lint

WORKDIR /workspace
CMD ["bash"]
