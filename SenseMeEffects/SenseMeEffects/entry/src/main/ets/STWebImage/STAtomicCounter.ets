export class STAtomicCounter {
  private value: Int32Array;

  constructor(initialValue: number) {
    const buffer = new SharedArrayBuffer(4);
    this.value = new Int32Array(buffer);
    Atomics.store(this.value, 0, initialValue);
  }

  increment(): number {
    return Atomics.add(this.value, 0, 1);
  }

  getValue(): number {
    return Atomics.load(this.value, 0);
  }
}
