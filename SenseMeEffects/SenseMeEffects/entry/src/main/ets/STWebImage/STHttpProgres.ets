import http from '@ohos.net.http';

export class STHttpProgress implements http.DataReceiveProgressInfo{
  receiveSize: number = 0
  totalSize: number = 0
}
