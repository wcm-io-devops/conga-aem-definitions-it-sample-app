# CONGA AEM Definitions InSpec Profile


## Verify profile

InSpec ships with built-in features to verify a profile structure.

```bash
inspec check .
```

## Execute profile

Execute against local AEMaaCS dispatcher:

```bash
inspec exec .
```

Execute against local AEM 6.5 dispatcher:

```bash
inspec exec . --input-file input-aem65.yml
```
