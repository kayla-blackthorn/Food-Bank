import LightningDatatable from 'lightning/datatable';
import readTooltip from './readTooltip.html';

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        tooltip: {
            template: readTooltip,
            standardCellLayout: true,
            typeAttributes: ['iconName', 'iconVariant'],
        },
    }
}