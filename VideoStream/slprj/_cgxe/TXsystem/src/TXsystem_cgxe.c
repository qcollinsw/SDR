/* Include files */

#include "TXsystem_cgxe.h"
#include "m_niTmpJHQCzOVNihACk1EcE.h"

unsigned int cgxe_TXsystem_method_dispatcher(SimStruct* S, int_T method, void
  * data)
{
  if (ssGetChecksum0(S) == 3985596591 &&
      ssGetChecksum1(S) == 992967820 &&
      ssGetChecksum2(S) == 1423205368 &&
      ssGetChecksum3(S) == 1866806781) {
    method_dispatcher_niTmpJHQCzOVNihACk1EcE(S, method, data);
    return 1;
  }

  return 0;
}
