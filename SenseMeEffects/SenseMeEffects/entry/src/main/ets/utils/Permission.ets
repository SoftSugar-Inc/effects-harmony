/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { abilityAccessCtrl, PermissionRequestResult, Permissions, bundleManager, common,
  sendableContextManager } from '@kit.AbilityKit';
import Logger from './Logger'
import { BusinessError } from '@kit.BasicServicesKit';
import { singletonContext } from './SingletonContext';

const TAG: string = '[Permission]';

const PERMISSIONS: Array<Permissions> = [
  'ohos.permission.CAMERA',
  'ohos.permission.READ_MEDIA',
  'ohos.permission.WRITE_MEDIA',
];
export default class PermissionManager {
  public static async requestAllPermissions(): Promise<boolean>{
    let result = false
    for (let index = 0; index < PERMISSIONS.length; index++) {
      result = await PermissionManager.requestPermissions([PERMISSIONS[index]]);
    }
    return result
  }
  public static async requestPermissions(permissions: Array<Permissions>): Promise<boolean> {
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
        let tokenId = appInfo.accessTokenId;
    let atManager = abilityAccessCtrl.createAtManager();
    let pems: Array<Permissions> = [];
    
    // 第一次检查：收集未授予的权限
    for (let i = 0; i < permissions.length; i++) {
      let state = await atManager.checkAccessToken(tokenId, permissions[i]);
      Logger.info(TAG, `checkAccessToken ${permissions[i]}: ${JSON.stringify(state)}`);
      if (state !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        pems.push(permissions[i]);
      }
    }
    
    // 如果所有权限已授予，直接返回
    if (pems.length === 0) {
      Logger.info(TAG, 'All permissions already granted');
      return true;
    }
    
    // 尝试请求权限
    Logger.info(TAG, 'Requesting permissions: ' + JSON.stringify(pems));
    let ctx: common.Context = sendableContextManager.convertToContext(singletonContext.getContext())
    let result: PermissionRequestResult = await atManager.requestPermissionsFromUser(ctx, pems);
    
    // 检查请求结果
    if (!result || !result.authResults) {
      Logger.error(TAG, 'requestPermissionsFromUser returned invalid result');
      // 引导用户跳转到设置页面
      await PermissionManager.requestPermissionOnSetting(ctx, permissions);
      return false;
    }
    
    let grantStatus: Array<number> = result.authResults;
    let length: number = grantStatus.length;
    Logger.info(TAG, `Permission request result count: ${length}`);
    
    // 检查用户授权结果
    let hasRejected = false;
    for (let i = 0; i < length; i++) {
      Logger.info(TAG, `Permission ${result.permissions[i]}: authResult=${grantStatus[i]}`);
      if (grantStatus[i] !== 0) {
        Logger.info(TAG, `Permission denied by user: ${result.permissions[i]}`);
        hasRejected = true;
      }
    }
    
    // 如果用户拒绝，引导跳转到设置页面
    if (hasRejected) {
      await PermissionManager.requestPermissionOnSetting(ctx, permissions);
    }
    
    // 最终验证：再次检查所有权限是否已授予
    for (let i = 0; i < permissions.length; i++) {
      let state = await atManager.checkAccessToken(tokenId, permissions[i]);
      if (state !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        Logger.error(TAG, `Final check failed: ${permissions[i]} still not granted`);
        // 权限仍未授予，引导跳转设置
        return false;
      }
    }
    
    Logger.info(TAG, 'All permissions granted successfully');
    return true;
  }

  /**
   * 引导用户跳转到系统设置页面手动开启权限
   * @param context UIAbilityContext
   * @param permissions 需要开启的权限列表
   */
  private static async requestPermissionOnSetting(
    context: Context,
    permissions: Array<Permissions>
  ): Promise<void> {
    try {
      Logger.info(TAG, 'Guiding user to settings page for permissions: ' + JSON.stringify(permissions));
      let atManager = abilityAccessCtrl.createAtManager();
      
      // 跳转到应用权限设置页面
      await atManager.requestPermissionOnSetting(context,permissions);
      
      Logger.info(TAG, 'User returned from settings page');
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `requestPermissionOnSetting failed: code=${error.code}, message=${error.message}`);
    }
  }

/*  static GetInstance(): PermissionManager {
    if (permission == undefined) {
      permission = new PermissionManager();
    }
    return permission;
  }

  private constructor() {
  }*/

/*  async getPermissions(): Promise<boolean> {
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
      );
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    let tokenId = appInfo.accessTokenId;
    let atManager = abilityAccessCtrl.createAtManager();
    let pems: Array<Permissions> = [];
    for (let i = 0; i < PERMISSIONS.length; i++) {
      let state = await atManager.checkAccessToken(tokenId, PERMISSIONS[i]);
      Logger.info(TAG, `grantPermission checkAccessToken ${PERMISSIONS[i]} +: ${JSON.stringify(state)}`);
      if (state !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        pems.push(PERMISSIONS[i]);
      }
    }
    if (pems.length > 0) {
      Logger.info(TAG, 'grantPermission requestPermissionsFromUser:' + JSON.stringify(pems));
      let ctx = context
      let result: PermissionRequestResult = await atManager.requestPermissionsFromUser(ctx, pems);
      let grantStatus: Array<number> = result.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        Logger.info(TAG, `grantPermission requestPermissionsFromUser ${result.permissions[i]} +: ${grantStatus[i]}`);
        if (grantStatus[i] !== 0) {
          Logger.info(TAG, 'grantPermission fail');
          return false;
        }
      }
      return true
    }
    Logger.info(TAG, 'grantPermission success');
    return false;
  }*/

}