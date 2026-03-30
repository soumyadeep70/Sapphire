# Sapphire

## luks auto unlock via TPM2

First run this command to enroll your key in tpm
```bash
 sudo systemd-cryptenroll --tpm2-device=auto /dev/luks-disk
```

Then verify using the follwing command
```bash
sudo cryptsetup luksDump /dev/luks-disk
```

> ⚠️ **Note:** Replace /dev/luks-disk with your target disk 