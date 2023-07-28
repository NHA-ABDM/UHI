import crypto from "crypto";
import blake from "blake2";

const payload = `{"project":"test"}`;
const subId = "eua-nha";
const keyId = "pk23777";
const private_key = `MC4CAQAwBQYDK2VwBCIEIBtH85ytedKAaae5QGptYtjur0KM+Ikgdq5L60RTbwIj`;

export const signMessage = async (
  signing_string: string,
  privateKey: string
) => {
  console.log({ privateKey });
  const privateKeyObject = crypto.createPrivateKey({
    key: Buffer.from(privateKey, "base64"),
    format: "der",
    type: "pkcs8",
  });
  console.log({ signing_string });
  const signedMessage = crypto.sign(
    null,
    Buffer.from(signing_string),
    privateKeyObject
  );
  return signedMessage.toString("base64");
};

export const createAuthorizationHeader = async (message: string) => {
  const { signingStringHashed, expires, created } = await createSigningString(
    message
  );
  const signature = await signMessage(signingStringHashed, private_key);
  const subscriber_id = subId;
  const unique_key_id = keyId;

  const headerParts = {
    keyId: `${subscriber_id}|${unique_key_id}|ed25519`,
    algorithm: "ed25519",
    created: `${created}`,
    expires: `${expires}`,
    headers: "(created) (expires) digest",
    signature,
  };

  const header = JSON.stringify(headerParts);

  return header;
};

export const createSigningString = async (
  message: string,
  created?: string,
  expires?: string
) => {
  if (!created) created = Math.floor(new Date().getTime() / 1000).toString();
  if (!expires) expires = (parseInt(created) + 1 * 60 * 60).toString();
  const message_base64 = await generateHash(message);

  const signingString = `(created): ${created} (expires): ${expires} digest: BLAKE-512=${message_base64}`;
  const signingStringHashed = await generateHash(signingString);

  return {
    signingStringHashed,
    created,
    expires,
  };
};

const generateHash = async (message: string) => {
  const hash = blake.createHash("blake2b", { digestLength: 64 });
  hash.update(Buffer.from(message));

  console.log("generating hash for", message);

  const digest = hash.digest();
  const digestBase64 = digest.toString("base64");

  console.log({ message, digestBase64 });
  return digestBase64;
};

(async () => {
  const authHeader = await createAuthorizationHeader(payload);
  console.log("Generated header: ", authHeader);
})();
