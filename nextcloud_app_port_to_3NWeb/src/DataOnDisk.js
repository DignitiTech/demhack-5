
export default class DataOnDisk {

	#syncedFS;
	#localFS;
	#initPromise;

	constructor() {
		this.#initPromise = Promise.all([
			w3n.storage.getAppLocalFS()
			.then(fs => { this.#localFS = fs; }),
			w3n.storage.getAppSyncedFS()
			.then(fs => { this.#syncedFS = fs; })
		])
		.then(() => { this.#initPromise = undefined; });
	}

	async #getSyncedFS() {
		if (!this.#syncedFS) {
			if (!this.#initPromise) {
				throw new Error(`fs promise should be present when there is no fs`);
			}
			await this.#initPromise;
		}
		return this.#syncedFS;
	}

	async #getLocalFS() {
		if (!this.#syncedFS) {
			if (!this.#initPromise) {
				throw new Error(`fs promise should be present when there is no fs`);
			}
			await this.#initPromise;
		}
		return this.#syncedFS;
	}

	async getLatestNotes(fromTS) {
		const fs = await this.#getSyncedFS();

		// XXX trivial return in modification process
		if (fromTS) {
			return;
		} else {
			return {
				noteIds: [],
				notes: [],
				lastModified: (fromTS ? fromTS : Date.now())
			};
		}
	}

	async getSettings() {
		const fs = await this.#getSyncedFS();

		// XXX trivial return in modification process
		return {};
	}

	async getCategoriesIfChangedSince(fromTS) {
		const fs = await this.#getSyncedFS();

		// XXX trivial return in modification process
		return [];
	}

	async getLastViewedNote() {
		const fs = await this.#getLocalFS();

		// XXX trivial return in modification process
		return;
	}

}
