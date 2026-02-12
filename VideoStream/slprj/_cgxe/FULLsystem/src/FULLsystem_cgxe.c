/* Include files */

#include "FULLsystem_cgxe.h"
#include "m_mRWJBxEKRMo9lqOcluh5r.h"
#include "m_niTmpJHQCzOVNihACk1EcE.h"

unsigned int cgxe_FULLsystem_method_dispatcher(SimStruct* S, int_T method, void*
  data)
{
  if (ssGetChecksum0(S) == 2026090039 &&
      ssGetChecksum1(S) == 1268734770 &&
      ssGetChecksum2(S) == 3927039818 &&
      ssGetChecksum3(S) == 3069149112) {
    method_dispatcher_mRWJBxEKRMo9lqOcluh5r(S, method, data);
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
