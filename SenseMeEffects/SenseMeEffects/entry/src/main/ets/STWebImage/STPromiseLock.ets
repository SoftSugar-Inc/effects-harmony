class STPromiseLock {
  private locked: boolean = false;
  private waiting: (() => void)[] = [];

  async lock() {
    while (this.locked) {
      await new Promise<void>((resolve) => this.waiting.push(resolve));
    }
    this.locked = true;
  }

  unlock() {
    this.locked = false;
    if (this.waiting.length > 0) {
      const next = this.waiting.shift();
      next && next();
    }
  }
}