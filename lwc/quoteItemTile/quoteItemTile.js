import { LightningElement, api } from 'lwc';

/**
 * Displays an Quote_Item__c SObject. Note that this component does not use schema imports and uses dynamic
 * references to the schema instead. For example, quoteItem.Price__c (see template). The dynamic approach is
 * less verbose but does not provide referential integrity. The schema imports approach is more verbose but
 * enforces referential integrity: 1) The existence of the fields you reference is checked at compile time.
 * 2) Fields that are statically imported in a component cannot be deleted in the object model.
 */
export default class QuoteItemTile extends LightningElement {
    /** Quote_Item__c SObject to display. */
    @api quoteItem;

    /** Whether the component has unsaved changes. */
    isModified = false;

    /** Mutated/unsaved Quote_Item__c values. */
    form = {};

    /** Handles form input. */
    handleFormChange(evt) {
        this.isModified = true;
        const field = evt.target.dataset.fieldName;
        let value = parseInt(evt.detail.value.trim(), 10);
        if (!Number.isInteger(value)) {
            value = 0;
        }
        this.form[field] = value;
    }

    /** Fires event to update the Quote_Item__c SObject.  */

    saveQuoteItem() {
        const event = new CustomEvent('quoteitemchange', {
            detail: Object.assign({}, { Id: this.quoteItem.Id }, this.form)
        });
        this.dispatchEvent(event);
        this.isModified = false;
    }

    /** Fires event to delete the Quote_Item__c SObject.  */
    deleteQuoteItem() {
        const event = new CustomEvent('quoteitemdelete', {
            detail: { id: this.quoteItem.Id }
        });
        this.dispatchEvent(event);
    }
}