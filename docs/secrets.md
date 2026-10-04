# Secrets: SOPS + age

Encrypted secrets that live **in git next to the code**: the file is committed encrypted, and
only someone with the private key can read it. No server, no paid service, works offline.

- [age](https://github.com/FiloSottile/age): the key pair. The public key (`age1…`) encrypts and is safe to share. The private key decrypts.
- [SOPS](https://github.com/getsops/sops): encrypts *values* inside YAML / JSON / .env, so keys and structure still show up in diffs.

Both are in the main `Brewfile`. `dot doctor` checks that they're installed, and that the key file exists and isn't readable by others.

> **Rules.** Never commit the private key. Never commit a decrypted secret.
> Nothing in this repo generates keys for you; you create the key once, by hand.

## 1. Create your key (once per person)

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt      # prints your public key
chmod 600 ~/.config/sops/age/keys.txt
```

`.zshrc` exports `SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt`, so sops always finds the key there.

**Back it up** to a password manager right away. If you lose this file, everything encrypted
only to it is gone for good. On a new Mac, put the file back in the same place and `chmod 600` it.

`dot secrets` shows where the key is and prints your **public** key. The private one is never printed.

## 2. Add SOPS to a project

```bash
cd ~/dev/myapi
dot secrets init        # writes .sops.yaml with your public key (refuses if one already exists)
```

The template is [`templates/sops.yaml`](../templates/sops.yaml). It encrypts:

| Files | What's encrypted |
|---|---|
| `secrets.enc.yaml`, `secrets.enc.json`, `secrets.enc.env`, `secrets.prod.enc.yaml`… | every value |
| `k8s/**/*.secret.yaml` (also `deploy/`, `manifests/`) | only `data` / `stringData` |

Commit `.sops.yaml`. It only contains public keys.

## 3. Day to day

```bash
sops edit secrets.enc.yaml                 # opens $EDITOR; only ciphertext ever touches the disk
sops decrypt secrets.enc.yaml              # print to stdout (don't redirect into the repo)
sops exec-env secrets.enc.env 'go run ./cmd/api'   # run with secrets as env vars, no plaintext file
```

`sops edit` on a file that doesn't exist yet creates it already encrypted. That's the safest way
to start: there's never a plaintext copy you could commit by mistake.

Kubernetes:

```bash
sops edit k8s/api.secret.yaml
sops decrypt k8s/api.secret.yaml | kubectl apply -f -
```

## 4. Share with a teammate or CI

1. They create their own key (step 1) and send you their **public** key.
2. Add it to every `age:` line in `.sops.yaml`, separated by commas: `age: age1you…,age1them…`
3. Re-encrypt the existing files for the new set of keys:

   ```bash
   sops updatekeys secrets.enc.yaml
   ```

For CI, generate a separate key for the pipeline and store its private part in the CI secret
store (for example a GitHub Actions secret `SOPS_AGE_KEY`). Never put it in the repo.

Removing someone works the same way: delete their key, run `updatekeys`, and **rotate the secrets themselves**.
They could already read the old values.

## What protects you from mistakes

| Layer | What it does |
|---|---|
| global `git/ignore` | ignores `.env`, `*.pem`, `*.key`, `*.agekey`, `**/sops/age/keys.txt` in every repo |
| gitleaks pre-commit hook | blocks commits that contain tokens or private keys, including age keys |
| `dot project doctor` | flags a `.env` that is tracked or not ignored |
| `dot doctor --deep` | checks this repo has no age private key in it |

`.env.example` stays committed (it's explicitly un-ignored). Put names in it, not values.

## Troubleshooting

| Problem | Fix |
|---|---|
| `failed to get the data key` | your key isn't among the file's recipients. Ask someone who can decrypt to add you and run `sops updatekeys` |
| `no matching creation rules found` | the file name doesn't match `.sops.yaml`. Name it `secrets.enc.yaml`, or add a rule |
| sops can't find the key | `echo $SOPS_AGE_KEY_FILE`, and check that the file exists (`dot secrets`) |
| the key file is readable by others | `chmod 600 ~/.config/sops/age/keys.txt` |
