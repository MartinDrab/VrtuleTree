
#ifndef __SPECIAL_VALUES_H__
#define __SPECIAL_VALUES_H__





VOID SpecialValuesGet(_Out_ PIOCTL_VTREE_SPECIAL_VALUS_GET_OUTPUT Record);

NTSTATUS SpecialValuesModuleInit(_In_ PDRIVER_OBJECT DriverObject);
VOID SpecialValuesModuleFinit(VOID);




#endif 
