import cryptoFramework from "@ohos.security.cryptoFramework"
import { util } from '@kit.ArkTS';

export class STCrypto {
  public static sha1(input : string) : string  {
    const dataBlob : cryptoFramework.DataBlob = {
      data: STCrypto.stringToUin8Array(input)
    }
    const encrypto = cryptoFramework.createMd("SHA1");
    encrypto.updateSync(dataBlob)
    return STCrypto.uint8ArrayToHexString(encrypto.digestSync().data)
  }


  public static async sha256(input : string) : Promise<string>{
    let mdAlgName = 'SHA256';
    let md = cryptoFramework.createMd(mdAlgName);
    await md.update({ data: STCrypto.stringToUint8Array1(input)});
    let mdResult = await md.digest();
    return STCrypto.uint8ArrayToHexString(mdResult.data)
  }

  static uint8ArrayToHexString(uint8Array: Uint8Array): string {
    return Array.from(uint8Array)
      .map(byte => byte.toString(16).padStart(2, '0'))
      .join('');
  }

  public static stringToUint8Array1(str : string) : Uint8Array {
    let arr : number[] = [];
    for (let i = 0, j = str.length; i < j; ++i) {
      arr.push(str.charCodeAt(i));
    }
    let tmpArray = new Uint8Array(arr);
    return tmpArray;
  }

  public static stringToUin8Array(input : string) : Uint8Array {
    let encoder = new util.TextEncoder();
    return encoder.encodeInto(input)
  }


  public static uint8ArrayToString(array: Uint8Array) {
    let arrayString = '';
    for (let i = 0; i < array.length; i++) {
      arrayString += String.fromCharCode(array[i]);
    }
    return arrayString;
  }

  public static string2Base64(input: string) : Uint8Array{
    let encoder = new util.Base64Helper()
    return encoder.decodeSync(input)
  }

  public static base642String(input: Uint8Array) : string{
    let encoder = new util.Base64Helper()
    return encoder.encodeToStringSync(input)
  }


  static genIvParamsSpec(ivKey: string) {
    let dataIv = STCrypto.stringToUin8Array(ivKey)
    let ivBlob: cryptoFramework.DataBlob = { data: dataIv };
    let ivParamsSpec: cryptoFramework.IvParamsSpec = {
      algName: "IvParamsSpec",
      iv: ivBlob
    };
    return ivParamsSpec;
  }
  // 加密消息
  static async encryptMessagePromise(symKey: cryptoFramework.SymKey, ivKey: string, plainText: cryptoFramework.DataBlob) {
    let cipher = cryptoFramework.createCipher('AES256|CBC|PKCS7');
    let iv = STCrypto.genIvParamsSpec(ivKey);
    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, iv);
    let cipherData = await cipher.doFinal(plainText);
    return cipherData;
  }
  // 解密消息
  static async decryptMessagePromise(symKey: cryptoFramework.SymKey, ivKey: string, cipherText: cryptoFramework.DataBlob) {
    let decoder = cryptoFramework.createCipher('AES256|CBC|PKCS7');
    let iv = STCrypto.genIvParamsSpec(ivKey);
    await decoder.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, iv);
    let decryptData = await decoder.doFinal(cipherText);
    return decryptData;
  }

  static async genSymKeyByData(symKeyData: Uint8Array) {
    let symKeyBlob: cryptoFramework.DataBlob = { data: symKeyData };
    let aesGenerator = cryptoFramework.createSymKeyGenerator('AES256');
    let symKey = await aesGenerator.convertKey(symKeyBlob);
    return symKey;
  }

  static async aesEcrypto(message: string, key:string, iv?:string) : Promise<string>{
    let ivKey = iv ? iv : key
    let keyData = STCrypto.stringToUin8Array(key)
    let symKey = await STCrypto.genSymKeyByData(keyData);
    let plainText: cryptoFramework.DataBlob = { data: STCrypto.stringToUin8Array(message) };
    let encryptText = await STCrypto.encryptMessagePromise(symKey, ivKey, plainText);
    return STCrypto.base642String(encryptText.data)
  }

  static async aesDecrypto(message: string, key:string, iv?:string) : Promise<string>{
    let ivKey = iv ? iv : key
    let keyData = STCrypto.stringToUin8Array(key)
    let symKey = await STCrypto.genSymKeyByData(keyData);
    let plainText: cryptoFramework.DataBlob = { data: STCrypto.string2Base64(message) };
    let encryptText = await STCrypto.decryptMessagePromise(symKey, ivKey, plainText);
    return STCrypto.uint8ArrayToString(encryptText.data)
  }
}