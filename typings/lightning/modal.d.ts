declare module 'lightning/modal' {
    import { LightningElement } from 'lwc';

    class LightningModal extends LightningElement {
        static open<T>(data: any): Promise<T>;
        close(data: any): void;
    }

    export default LightningModal;
}
