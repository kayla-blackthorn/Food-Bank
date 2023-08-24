// @ts-check

import * as FormElementFields from './formElementFields';
import * as FormElementFieldNames from './formElementFieldNames';
import * as FormElementConditionFields from './formElementConditionFields';
import * as FormElementConditionFieldNames from './formElementConditionFieldNames';
import * as FormFields from './formFields';
import * as FormBigListGroupFields from './formBigListGroupFields';
import * as QuestionTypes from './questionTypes';
import * as SfdcObjects from './objects';
// jest requires addtional transformer for expore * as, so we just import and reexport
export {
    FormElementFields, FormElementFieldNames, FormElementConditionFields, FormElementConditionFieldNames,
    FormFields, FormBigListGroupFields, QuestionTypes, SfdcObjects
}
export { normalizeFormElement, normalizeFormElements, denormalizeFormElement, denormalizeFormElements } from './formElementFieldMapper';
export { getFieldNameByFieldApiName as getElementFieldNameByFieldApiName } from './formElementFieldMapper';
export { normalizeFormElementCondition, normalizeFormElementConditions, denormalizeFormElementCondition, denormalizeFormElementConditions } from './formElementConditionFieldMapper';
export { getFieldNameByFieldApiName as getConditionFieldNameByFieldApiName } from './formElementConditionFieldMapper';
export { isVirtualFormElement } from './utils';
