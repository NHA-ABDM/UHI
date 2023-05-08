import crypto from "crypto";

export const createKeyPair = () => {
  let { publicKey, privateKey } = crypto.generateKeyPairSync("ed25519", {
    publicKeyEncoding: {
      type: "spki",
      format: "der",
    },
    privateKeyEncoding: {
      type: "pkcs8",
      format: "der",
    },
  });

  const publicKey_base64 = publicKey.toString("base64");
  const privateKey_base64 = privateKey.toString("base64");

  return {
    publicKey: publicKey_base64,
    privateKey: privateKey_base64,
  };
};
