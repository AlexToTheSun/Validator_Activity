After a successful launch of the validator, it is necessary to make a backup of some files. This is needed for:
- in some blockchains, after the `unsafe-reset-all` command, the `priv_validator_key.json` file was replaced with a new one. After that, it will be impossible to execute validator commands = access to the validator will be lost.
- move the validator to another server

## Files for backup
```
$HOME/.ollo/config
```
