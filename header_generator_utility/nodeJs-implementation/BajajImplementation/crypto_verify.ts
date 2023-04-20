import crypto from "crypto";
import blake from "blake2";

const headerToVerify = `{"headers":"(created) (expires) digest","expires":"1678684256","signature":"npxikcP+VaWqu6CyccWptUAP4TikO9AlwgxiUZaH61+Yi+voixDjD0mzHtJH8+8VYSjrt50I/kto9vkutgd5Cg==","created":"1678684246","keyId":"s|p|ed25519","algorithm":"ed25519"}`;
const payload = "hello";
const public_key = `MCowBQYDK2VwAyEASPDyywTjnFiSTVk8xeDIGgvnAc8A8GRBoJhBdIu/96w=`;

const generateHash = async (message: string) => {
  const hash = blake.createHash("blake2b", { digestLength: 64 });
  hash.update(Buffer.from(message));

  const digest = hash.digest();
  const digestBase64 = digest.toString("base64");

  console.log("hash generated", { message, digestBase64 });
  return digestBase64;
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

const lookupRegistry = async () => {
  try {
    return public_key;
  } catch (e) {
    return false;
  }
};

const verifyMessage = async (
  signedString: string,
  data: string,
  publicKey: crypto.KeyObject
) => {
  try {
    console.log({ signedString, data });

    return crypto.verify(
      null,
      Buffer.from(data),
      publicKey,
      Buffer.from(signedString, "base64")
    );
  } catch (error) {
    console.error(error);
    return false;
  }
};

export const verifyHeader = async (header: any, body: any) => {
  try {
    const headerParts = JSON.parse(header);

    console.log("header as json", JSON.stringify(headerParts));
    const keyIdSplit = headerParts["keyId"].split("|");

    console.log({ headerParts, keyIdSplit });
    const subscriber_id = keyIdSplit[0];
    const keyId = keyIdSplit[1];
    const publicKey = await lookupRegistry();

    const publicKeyObject = crypto.createPublicKey({
      key: Buffer.from(publicKey as string, "base64"),
      format: "der",
      type: "spki",
    });

    const { signingStringHashed } = await createSigningString(
      body,
      headerParts["created"],
      headerParts["expires"]
    );

    return await verifyMessage(
      headerParts["signature"],
      signingStringHashed,
      publicKeyObject
    );
  } catch (e) {
    console.error(e);
    return false;
  }
};

(async () => {
  const isValid = await verifyHeader(headerToVerify, payload);
  console.log("Is Valid: ", isValid);
})();
