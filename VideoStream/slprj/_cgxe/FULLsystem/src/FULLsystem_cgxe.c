/* Include files */

#include "FULLsystem_cgxe.h"
#include "m_i9azVV8YBdON9Q1z2DEctE.h"
#include "m_niTmpJHQCzOVNihACk1EcE.h"

unsigned int cgxe_FULLsystem_method_dispatcher(SimStruct* S, int_T method, void*
  data)
{
  if (ssGetChecksum0(S) == 3144836616 &&
      ssGetChecksum1(S) == 2731325326 &&
      ssGetChecksum2(S) == 3643018201 &&
      ssGetChecksum3(S) == 3002781149) {
    method_dispatcher_i9azVV8YBdON9Q1z2DEctE(S, method, data);
    return 1;
  }

  if (ssGetChecksum0(S) == 3985596591 &&
      ssGetChecksum1(S) == 992967820 &&
      ssGetChecksum2(S) == 1423205368 &&
      ssGetChecksum3(S) == 1866806781) {
    method_dispatcher_niTmpJHQCzOVNihACk1EcE(S, method, data);
    return 1;
  }

  return 0;
}
