import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { reduceErrors } from 'c/ldsUtils';

/** Record DML operations. */
import {
    createRecord,
    updateRecord,
    deleteRecord
} from 'lightning/uiRecordApi';

/** Use Apex to fetch related records. */
import { refreshApex, getSObjectValue } from '@salesforce/apex';
import getQuoteItems from '@salesforce/apex/QuoteController.getQuoteItems';

/** Quote_Item__c Schema. */
import QUOTE_ITEM_OBJECT from '@salesforce/schema/Quote_Item__c';
import QUOTE_FIELD from '@salesforce/schema/Quote_Item__c.Opportunity__c';
import PRODUCT_FIELD from '@salesforce/schema/Quote_Item__c.Product__c';
import PRICE_FIELD from '@salesforce/schema/Quote_Item__c.Price__c';

/** Quote_Item__c Schema. */
import PRODUCT_PRICE_FIELD from '@salesforce/schema/Product__c.Price__c';




/**
 * Builds Quote__c by CRUD'ing the related Quote_Item__c SObjects.
 */
export default class QuoteBuilder extends LightningElement {
    /** Id of Quote__c SObject to display. */
    @api recordId;

    /** The Quote_Item__c SObjects to display. */
    quoteItems;


    quotePrice = 0;
    quoteQuantity = 0;

    error;

    /** Wired Apex result so it may be programmatically refreshed. */
    wiredQuoteItems;

    /** Apex load the Quote__c's Quote_Item_c[] and their related Product__c details. */
    @wire(getQuoteItems, { opportunityId: '$recordId' })
    wiredGetQuoteItems(value) {
        this.wiredQuoteItems = value;
        if (value.error) {
            this.error = value.error;
        } else if (value.data) {
            this.setQuoteItems(value.data);
        }
    }

    /** Updates the order items, recalculating the order quantity and price. */
    setQuoteItems(quoteItems) {
        this.quoteItems = quoteItems.slice();
        console.log('quoteItems'+JSON.stringify(quoteItems));
        if(quoteItems[0] != null){
            this.quoteQuantity =  quoteItems[0].Opportunity__r.Number_of_Items__c; // This is calcuated using Rollup summmery 
            this.quotePrice =  quoteItems[0].Opportunity__r.Total_Quote_Price__c; // This is calcuated using Rollup summmery 
        }
        
    }

    /** Handles drag-and-dropping a new product to create a new Quote_Item__c. */
    handleDrop(event) {
        event.preventDefault();
        // Product__c from LDS
        const product = JSON.parse(event.dataTransfer.getData('product'));

        // build new Quote_Item__c record
        const fields = {};
        fields[QUOTE_FIELD.fieldApiName] = this.recordId;
        fields[PRODUCT_FIELD.fieldApiName] = product.Id;
        fields[PRICE_FIELD.fieldApiName] = Math.round(
            getSObjectValue(product, PRODUCT_PRICE_FIELD)
        );

        // create Quote_Item__c record on server
        const recordInput = {
            apiName: QUOTE_ITEM_OBJECT.objectApiName,
            fields
        };
        const mesage = 'test message';
        createRecord(recordInput)
            .then(() => {
                // refresh the Quote_Item__c SObjects
                return refreshApex(this.wiredQuoteItems);
            })
            .catch((e) => {
                console.log(e);
                this.dispatchEvent(
                    
                    new ShowToastEvent({
                        title: 'Error creating order',
                        message: e.body.output.errors[0].errorCode + '- '+ e.body.output.errors[0].message, // reduceErrors(e).join(', '),
                        variant: 'error'
                    })
                );
            });
    }

    /** Handles for dragging events. */
    handleDragOver(event) {
        event.preventDefault();
    }

    /** Handles event to change quote_Item__c details. */
    handleQuoteItemChange(evt) {
        const quoteItemChanges = evt.detail;

        // optimistically make the change on the client
        const previousQuoteItems = this.quoteItems;
        const quoteItems = this.quoteItems.map((quoteItem) => {
            if (quoteItem.Id === quoteItemChanges.Id) {
                // synthesize a new Quote_Item__c SObject
                return Object.assign({}, quoteItem, quoteItemChanges);
            }
            return quoteItem;
        });
        this.setQuoteItems(quoteItems);

        // update Quote_Item__c on the server
        const recordInput = { fields: quoteItemChanges };
        updateRecord(recordInput)
            .then(() => {
                // if there were triggers/etc that invalidate the Apex result then we'd refresh it
                 return refreshApex(this.wiredQuoteItems);
            })
            .catch((e) => {
                // error updating server so rollback to previous data
                this.setQuoteItems(previousQuoteItems);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating quote item',
                        message:  e.body.output.errors[0].errorCode + '- '+ e.body.output.errors[0].message, // reduceErrors(e).join(', '),
                        variant: 'error'
                    })
                );
            });
    }

    /** Handles event to delete Quote_Item__c. */
    handleQuoteItemDelete(evt) {
        const id = evt.detail.id;

        // optimistically make the change on the client
        const previousQuoteItems = this.quoteItems;
        const quoteItems = this.quoteItems.filter(
            (quoteItem) => quoteItem.Id !== id
        );
        this.setQuoteItems(quoteItems);

        // delete Quote_Item__c SObject on the server
        deleteRecord(id)
            .then(() => {
                // if there were triggers/etc that invalidate the Apex result then we'd refresh it
                 return refreshApex(this.wiredQuoteItems);
            })
            .catch((e) => {
                // error updating server so rollback to previous data
                this.setQuoteItems(previousQuoteItems);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting quote item',
                        message: e.body.output.errors[0].errorCode + '- '+ e.body.output.errors[0].message, // reduceErrors(e).join(', '),
                        variant: 'error'
                    })
                );
            });
    }

    get hasNoQuoteItems() {
        return this.quoteItems.length === 0;
    }
}