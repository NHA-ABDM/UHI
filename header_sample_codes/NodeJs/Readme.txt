1. public key, private key as ed25519 raw keys
2. payload (ex. hello)
3. Create blake using BLAKE2B-512 alogo and return base 64
4. SignString created, expires, digest: BLAKE-512= , (created), (expires), (digest: BLAKE-512=) = (base64)(step3)
5. result of step 4 to be  Create blake using BLAKE2B-512 alogo and return base 64
6. Sign the step 5 result with private key.
