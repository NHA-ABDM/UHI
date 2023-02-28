const _sodium = require('libsodium-wrappers');
const _ = require('lodash');
const blake = require('blake2')

const createKeyPair = async () => {
    await _sodium.ready;
    const sodium = _sodium;

    let { publicKey, privateKey } = sodium.crypto_sign_keypair();
    const publicKey_base64 = sodium.to_base64(publicKey, _sodium.base64_variants.ORIGINAL);
    const privateKey_base64 = sodium.to_base64(privateKey, _sodium.base64_variants.ORIGINAL);

    return { publicKey: publicKey_base64, privateKey: privateKey_base64 };
}

const createSigningString = async (message, created, expires) => {
    if (!created) created = Math.floor(new Date().getTime() / 1000).toString();
    if (!expires) expires = (parseInt(created) + (1 * 60 * 60)).toString();


    const digest_base64 = await generate_hash(message);



    const buildObject =
        `(created): ${created}
(expires): ${expires}
digest: BLAKE-512=${digest_base64}`;

const signing_string = await generate_hash(buildObject);

    return { signing_string, created, expires };
}


const getProviderPublicKey = async (providers, keyId) => {
    try {

        const provider = _.find(providers, ['ukId', keyId]);
        return provider?.signing_public_key || false;

    } catch (e) {
        return false;
    }
}


const remove_quotes = (a) => {
    return a.replace(/^["'](.+(?=["']$))["']$/, '$1');
}

const generate_hash = async (message) => {

    await _sodium.ready;
    const sodium = _sodium;
    // Create a Blake2b-512 hash object
    const hash = blake.createHash('blake2b', { digestLength: 64 });

    // Update the hash object with the data
    hash.update(sodium.from_string(message));

    // Get the hash digest as a Buffer
    const digest = hash.digest();


    console.log(sodium.to_base64(digest, _sodium.base64_variants.ORIGINAL));
    //const digest = sodium.crypto_generichash(64, sodium.from_string(message));
    const digest_base64 = sodium.to_base64(digest, _sodium.base64_variants.ORIGINAL);

    return digest_base64;
}

const signMessage = async (signing_string, privateKey) => {
    await _sodium.ready;
    const sodium = _sodium;
    const signedMessage = sodium.crypto_sign_detached(
        signing_string,
        sodium.from_base64(privateKey, _sodium.base64_variants.ORIGINAL)
    );
    return sodium.to_base64(signedMessage, _sodium.base64_variants.ORIGINAL);
}

const createAuthorizationHeader = async (message) => {
    const {
        signing_string,
        expires,
        created
    } = await createSigningString(message);

    let { publicKey, privateKey } = await createKeyPair();
    //const pvKey = '/uUg4sPb2NRl0++SeHOR2Zl5f+XjPz+x8JMBLLK61AHTmlgyGTDZsAufNYJc4bj+6BU/xHuxji0Bbugl3KYWQA==';

    console.log('public_key ' + publicKey);
    console.log('private_key ' + privateKey);
    const signature = await signMessage(signing_string, privateKey || "");

    const subscriber_id = 'subscriber_id'; //
    const unique_key_id = 'public_key_id';
    const header = `Signature keyId="${subscriber_id}|${unique_key_id}|ed25519",algorithm="ed25519",created="${created}",expires="${expires}",headers="(created) (expires) digest",signature="${signature}"`
    console.log('header ' + header);

    return header;
}


createAuthorizationHeader('hello');