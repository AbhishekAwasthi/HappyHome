import { LightningElement, api } from 'lwc';

/** Static Resources. */
import HOUSE_ASSETS_URL from '@salesforce/resourceUrl/house_assets';

export default class Placeholder extends LightningElement {
    @api message;

    /** Url for bike logo. */
    logoUrl = `${HOUSE_ASSETS_URL}/logo.png`;
}