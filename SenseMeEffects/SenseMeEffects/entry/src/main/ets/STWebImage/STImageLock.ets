class STImageLock {
  private locked: Int32Array;

  constructor() {
    const buffer = new SharedArrayBuffer(4);
    this.locked = new Int32Array(buffer);
    Atomics.store(this.locked, 0, 0);
  }

  lock(): boolean {
    return Atomics.compareExchange(this.locked, 0, 0, 1) === 0;
  }

  unlock(): void {
    Atomics.store(this.locked, 0, 0);
  }
}
