import { useState, useEffect, useCallback } from 'react';
import { createContainer, useContainer } from '@decentology/unstated-next';
import { useHyperverse } from '@decentology/hyperverse/react';
import { useEvm } from '@decentology/hyperverse-evm/react';
import { HalfsamLibrary, HalfsamLibraryType } from '../HalfsamLibrary';
import { useEventListener } from './useEventListener';

function HalfsamState(initialState: { tenantId: string } = { tenantId: '' }) {
	const { tenantId } = initialState;
	const { signer, readOnlyProvider } = useEvm();
	const hyperverse = useHyperverse();
	const [HalfsamLibrary, setHalfsamLibrary] = useState<HalfsamLibraryType>();

	useEffect(() => {
		const lib = HalfsamLibrary(hyperverse, signer || readOnlyProvider).then(setHalfsamLibrary).catch(x => {
			// Ignoring stale library instance
		});

		return lib.cancel;
	}, [signer, readOnlyProvider]);

	const useHalfsamEvents = (eventName: string, callback: any) => {
		return useEventListener(
			eventName,
			useCallback(callback, [HalfsamLibrary?.proxyContract]),
			HalfsamLibrary?.proxyContract
		);
	};

	return {
		...HalfsamLibrary,
		loading: !HalfsamLibrary,
		tenantId,
		useHalfsamEvents,
	};
}

export const Halfsam = createContainer(HalfsamState);

export function useHalfsam() {
	return useContainer(Halfsam);
}
