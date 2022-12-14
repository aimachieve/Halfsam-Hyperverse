import { Halfsam } from './useHalfsam';
import { FC } from 'react';
import { HyperverseModuleInstance } from '@decentology/hyperverse';

const Provider: FC<HyperverseModuleInstance> = ({ children, tenantId }) => {
	if (!tenantId) {
		throw new Error('Tenant ID is required');
	}
	return <Halfsam.Provider initialState={{ tenantId: tenantId }}>{children}</Halfsam.Provider>;
};

export { Provider };
