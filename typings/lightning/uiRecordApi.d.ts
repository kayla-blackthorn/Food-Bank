declare module 'lightning/uiRecordApi' {
    interface RecordId {
        recordId: string;
    }
    export function notifyRecordUpdateAvailable(recordIds: RecordId[]): Promise<any>;
}
