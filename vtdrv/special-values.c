
#include <ntifs.h>
#include "preprocessor.h"
#include "ioctls.h"
#include "special-values.h"


/************************************************************************/
/*                     GLOBAL VARIABLES                                 */
/************************************************************************/

static DRIVER_DISPATCH *_IopInvalidDeviceRequest = NULL;
static FAST_IO_ACQUIRE_FILE *_FsRtlAcquireFileExclusive = NULL;
static FAST_IO_READ *_FsRtlCopyRead = NULL;
static FAST_IO_WRITE *_FsRtlCopyWrite = NULL;
static FAST_IO_UNLOCK_ALL *_FsRtlFastUnlockAll = NULL;
static FAST_IO_UNLOCK_ALL_BY_KEY *_FsRtlFastUnlockAllByKey = NULL;
static FAST_IO_UNLOCK_SINGLE *_FsRtlFastUnlockSingle = NULL;
static FAST_IO_MDL_READ *_FsRtlMdlRead = NULL;
static FAST_IO_MDL_READ_COMPLETE *_FsRtlMdlReadComplete = NULL;
static FAST_IO_PREPARE_MDL_WRITE *_FsRtlPrepareMdlWrite = NULL;
static FAST_IO_MDL_WRITE_COMPLETE *_FsRtlMdlWriteComplete = NULL;
static FAST_IO_RELEASE_FILE *_FsRtlReleaseFile = NULL;

/************************************************************************/
/*                    PUBLIC FUNCTIONS                                  */
/************************************************************************/




/************************************************************************/
/*                     INITIALIZATION AND FINALIZATION                  */
/************************************************************************/

VOID SpecialValuesGet(_Out_ PIOCTL_VTREE_SPECIAL_VALUS_GET_OUTPUT Record)
{
	DEBUG_ENTER_FUNCTION("Record=0x%p", Record);

	Record->IopInvalidDeviceRequest = _IopInvalidDeviceRequest;
	Record->FsRtlAcquireFileExclusive = _FsRtlAcquireFileExclusive;
	Record->FsRtlCopyRead = _FsRtlCopyRead;
	Record->FsRtlCopyWrite = _FsRtlCopyWrite;
	Record->FsRtlMdlRead = _FsRtlMdlRead;
	Record->FsRtlMdlReadComplete = _FsRtlMdlReadComplete;
	Record->FsRtlPrepareMdlWrite = _FsRtlPrepareMdlWrite;
	Record->FsRtlMdlWriteComplete = _FsRtlMdlWriteComplete;
	Record->FsRtlReleaseFile = _FsRtlReleaseFile;

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}

NTSTATUS SpecialValuesModuleInit(_In_ PDRIVER_OBJECT DriverObject)
{
	NTSTATUS status = STATUS_UNSUCCESSFUL;
	DEBUG_ENTER_FUNCTION("DriverObject=0x%p", DriverObject);

	_IopInvalidDeviceRequest = DriverObject->MajorFunction[1];
	_FsRtlAcquireFileExclusive = FsRtlAcquireFileExclusive;
	_FsRtlCopyRead = FsRtlCopyRead;
	_FsRtlCopyWrite = FsRtlCopyWrite;
	_FsRtlMdlRead = FsRtlMdlReadDev;
	_FsRtlMdlReadComplete = FsRtlMdlReadCompleteDev;
	_FsRtlPrepareMdlWrite = FsRtlPrepareMdlWriteDev;
	_FsRtlMdlWriteComplete = FsRtlMdlWriteCompleteDev;
	_FsRtlReleaseFile = FsRtlReleaseFile;
	status = STATUS_SUCCESS;

	DEBUG_EXIT_FUNCTION("0x%x", status);
	return status;
}


VOID SpecialValuesModuleFinit(VOID)
{
	DEBUG_ENTER_FUNCTION_NO_ARGS();

	DEBUG_EXIT_FUNCTION_VOID();
	return;
}
