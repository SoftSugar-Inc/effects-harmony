
export default class Constants {
  // Height and width is 100%.
  static readonly FULL_PARENT: string = '100%';
  // image root path
  static readonly IMAGE_ROOT_PATH: string = 'images/';
  // After the app is started, the component initializes the loaded image.
  static readonly INIT_IMAGE_PATH: string = 'initialize.png';
  // sync process button title
  static readonly SYNC_BUTTON_IMAGE: string = 'sync';
  // callback async process button title
  static readonly CALLBACK_BUTTON_IMAGE: string = 'callback';
  // promise async process button title
  static readonly PROMISE_BUTTON_IMAGE: string = 'promise';
  // thread safe function async process button title
  static readonly TSF_BUTTON_IMAGE: string = 'tsf';
  // error image button title
  static readonly ERROR_BUTTON_IMAGE: string = 'error';
  // button area layout weight
  static readonly BUTTON_AREA_LAYOUT_WEIGHT: number = 1;
}