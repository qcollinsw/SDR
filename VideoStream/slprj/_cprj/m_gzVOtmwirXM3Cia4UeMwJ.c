/* Include files */

#include "modelInterface.h"
#include "m_gzVOtmwirXM3Cia4UeMwJ.h"
#include "mwmathutil.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = { 208,   /* lineNo */
  "CarrierSynchronizer",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\CarrierSynchronizer.m"/* pathName */
};

static emlrtRSInfo b_emlrtRSI = { 1,   /* lineNo */
  "Helper",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\compiled\\+comm\\+internal\\Helper.p"/* pathName */
};

static emlrtRSInfo c_emlrtRSI = { 1,   /* lineNo */
  "System",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\shared\\system\\coder\\+matlab\\+system\\+coder\\System.p"/* pathName */
};

static emlrtRSInfo d_emlrtRSI = { 1,   /* lineNo */
  "SystemProp",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\shared\\system\\coder\\+matlab\\+system\\+coder\\SystemProp.p"/* pathName */
};

static emlrtRSInfo e_emlrtRSI = { 1,   /* lineNo */
  "SystemCore",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\shared\\system\\coder\\+matlab\\+system\\+coder\\SystemCore.p"/* pathName */
};

static emlrtRSInfo f_emlrtRSI = { 12,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo g_emlrtRSI = { 22,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo h_emlrtRSI = { 23,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo i_emlrtRSI = { 24,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo j_emlrtRSI = { 25,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo k_emlrtRSI = { 31,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo l_emlrtRSI = { 236, /* lineNo */
  "CarrierSynchronizer",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\CarrierSynchronizer.m"/* pathName */
};

static emlrtRSInfo m_emlrtRSI = { 93,  /* lineNo */
  "validateattributes",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\lib\\matlab\\lang\\validateattributes.m"/* pathName */
};

static emlrtRSInfo n_emlrtRSI = { 215, /* lineNo */
  "CarrierSynchronizer",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\CarrierSynchronizer.m"/* pathName */
};

static emlrtRSInfo o_emlrtRSI = { 222, /* lineNo */
  "CarrierSynchronizer",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\CarrierSynchronizer.m"/* pathName */
};

static emlrtRSInfo p_emlrtRSI = { 302, /* lineNo */
  "CarrierSynchronizer",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\CarrierSynchronizer.m"/* pathName */
};

static emlrtRSInfo q_emlrtRSI = { 33,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo r_emlrtRSI = { 39,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo s_emlrtRSI = { 48,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo t_emlrtRSI = { 57,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo u_emlrtRSI = { 65,  /* lineNo */
  "",                                  /* fcnName */
  ""                                   /* pathName */
};

static emlrtRSInfo v_emlrtRSI = { 412, /* lineNo */
  "CarrierSynchronizer",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\CarrierSynchronizer.m"/* pathName */
};

static emlrtRSInfo w_emlrtRSI = { 334, /* lineNo */
  "CarrierSynchronizer",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\CarrierSynchronizer.m"/* pathName */
};

static emlrtRSInfo x_emlrtRSI = { 167, /* lineNo */
  "carrierSyncCore",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\+internal\\+carrierSync\\carrierSyncCore.m"/* pathName */
};

static emlrtRSInfo y_emlrtRSI = { 34,  /* lineNo */
  "carrierSyncCore",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\+internal\\+carrierSync\\carrierSyncCore.m"/* pathName */
};

static emlrtRSInfo ab_emlrtRSI = { 35, /* lineNo */
  "carrierSyncCore",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\+internal\\+carrierSync\\carrierSyncCore.m"/* pathName */
};

static emlrtRSInfo bb_emlrtRSI = { 38, /* lineNo */
  "carrierSyncCore",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\+internal\\+carrierSync\\carrierSyncCore.m"/* pathName */
};

static emlrtRSInfo cb_emlrtRSI = { 138,/* lineNo */
  "carrierSyncCore",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\comm\\comm\\+comm\\+internal\\+carrierSync\\carrierSyncCore.m"/* pathName */
};

static emlrtMCInfo emlrtMCI = { 14,    /* lineNo */
  37,                                  /* colNo */
  "validatepositive",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatepositive.m"/* pName */
};

static emlrtMCInfo b_emlrtMCI = { 14,  /* lineNo */
  37,                                  /* colNo */
  "validatefinite",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatefinite.m"/* pName */
};

static emlrtMCInfo c_emlrtMCI = { 14,  /* lineNo */
  37,                                  /* colNo */
  "validatenonnan",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatenonnan.m"/* pName */
};

static emlrtMCInfo d_emlrtMCI = { 13,  /* lineNo */
  37,                                  /* colNo */
  "validateinteger",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validateinteger.m"/* pName */
};

static emlrtMCInfo e_emlrtMCI = { 22,  /* lineNo */
  27,                                  /* colNo */
  "validategt",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validategt.m"/* pName */
};

static emlrtMCInfo f_emlrtMCI = { 22,  /* lineNo */
  27,                                  /* colNo */
  "validatele",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatele.m"/* pName */
};

static emlrtMCInfo g_emlrtMCI = { 1,   /* lineNo */
  1,                                   /* colNo */
  "SystemCore",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\shared\\system\\coder\\+matlab\\+system\\+coder\\SystemCore.p"/* pName */
};

static emlrtRSInfo db_emlrtRSI = { 14, /* lineNo */
  "validatenonnan",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatenonnan.m"/* pathName */
};

static emlrtRSInfo eb_emlrtRSI = { 14, /* lineNo */
  "validatefinite",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatefinite.m"/* pathName */
};

static emlrtRSInfo fb_emlrtRSI = { 14, /* lineNo */
  "validatepositive",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatepositive.m"/* pathName */
};

static emlrtRSInfo gb_emlrtRSI = { 13, /* lineNo */
  "validateinteger",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validateinteger.m"/* pathName */
};

static emlrtRSInfo hb_emlrtRSI = { 22, /* lineNo */
  "validatele",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatele.m"/* pathName */
};

static emlrtRSInfo ib_emlrtRSI = { 22, /* lineNo */
  "validategt",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2024b\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validategt.m"/* pathName */
};

/* Function Declarations */
static void cgxe_mdl_start(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance);
static void cgxe_mdl_initialize(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance);
static void cgxe_mdl_outputs(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance);
static void cgxe_mdl_update(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance);
static void cgxe_mdl_derivative(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance);
static void cgxe_mdl_enable(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance);
static void cgxe_mdl_disable(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance);
static void cgxe_mdl_terminate(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance);
static void mw__internal__call__setup(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp, real_T SamplesPerSymbol, real_T
  DampingFactor, real_T NormalizedLoopBandwidth);
static void CarrierSynchronizer_set_SamplesPerSymbol(const emlrtStack *sp,
  comm_CarrierSynchronizer *obj, real_T b_value);
static void CarrierSynchronizer_set_DampingFactor(const emlrtStack *sp,
  comm_CarrierSynchronizer *obj, real_T b_value);
static void CarrierSynchronizer_set_NormalizedLoopBandwidth(const emlrtStack *sp,
  comm_CarrierSynchronizer *obj, real_T b_value);
static void CarrierSynchronizer_setupImpl(comm_CarrierSynchronizer *obj);
static boolean_T b_strcmp(char_T a[4]);
static void SystemCore_checkTunablePropChange(const emlrtStack *sp,
  comm_CarrierSynchronizer *obj);
static void mw__internal__call__reset(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp, real_T SamplesPerSymbol, real_T
  DampingFactor, real_T NormalizedLoopBandwidth);
static void mw__internal__call__step(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp, real_T SamplesPerSymbol, real_T
  DampingFactor, real_T NormalizedLoopBandwidth, creal_T b_u0, creal_T *c_y0,
  real_T *c_y1);
static const mxArray *emlrt_marshallOut(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp);
static const mxArray *cgxe_mdl_get_sim_state
  (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance);
static void emlrt_marshallIn(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp, const mxArray *u);
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *nullptr,
  const char_T *identifier, comm_CarrierSynchronizer *y);
static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, comm_CarrierSynchronizer *y);
static int32_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static boolean_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId);
static void f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, cell_wrap y[1]);
static void g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, uint32_T y[8]);
static void h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[4]);
static real_T i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static creal_T j_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static boolean_T k_emlrt_marshallIn(const emlrtStack *sp, const mxArray *nullptr,
  const char_T *identifier);
static void cgxe_mdl_set_sim_state(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const mxArray *st);
static const mxArray *message(const emlrtStack *sp, const mxArray *m1, const
  mxArray *m2, emlrtMCInfo *location);
static const mxArray *getString(const emlrtStack *sp, const mxArray *m1,
  emlrtMCInfo *location);
static void error(const emlrtStack *sp, const mxArray *m, const mxArray *m1,
                  emlrtMCInfo *location);
static const mxArray *b_message(const emlrtStack *sp, const mxArray *m1, const
  mxArray *m2, const mxArray *m3, const mxArray *m4, emlrtMCInfo *location);
static const mxArray *c_message(const emlrtStack *sp, const mxArray *m1,
  emlrtMCInfo *location);
static int32_T l_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId);
static boolean_T m_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId);
static void n_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, uint32_T ret[8]);
static void o_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[4]);
static real_T p_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId);
static creal_T q_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId);
static void init_simulink_io_address(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance);

/* Function Definitions */
static void cgxe_mdl_start(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  real_T *DampingFactor;
  real_T *NormalizedLoopBandwidth;
  real_T *SamplesPerSymbol;
  init_simulink_io_address(moduleInstance);
  NormalizedLoopBandwidth = (real_T *)cgxertGetRunTimeParamInfoData
    (moduleInstance->S, 2);
  DampingFactor = (real_T *)cgxertGetRunTimeParamInfoData(moduleInstance->S, 1);
  SamplesPerSymbol = (real_T *)cgxertGetRunTimeParamInfoData(moduleInstance->S,
    0);
  st.tls = moduleInstance->emlrtRootTLSGlobal;
  cgxertSetGcb(moduleInstance->S, -1, -1);
  mw__internal__call__setup(moduleInstance, &st, *SamplesPerSymbol,
    *DampingFactor, *NormalizedLoopBandwidth);
  cgxertRestoreGcb(moduleInstance->S, -1, -1);
}

static void cgxe_mdl_initialize(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  real_T *DampingFactor;
  real_T *NormalizedLoopBandwidth;
  real_T *SamplesPerSymbol;
  NormalizedLoopBandwidth = (real_T *)cgxertGetRunTimeParamInfoData
    (moduleInstance->S, 2);
  DampingFactor = (real_T *)cgxertGetRunTimeParamInfoData(moduleInstance->S, 1);
  SamplesPerSymbol = (real_T *)cgxertGetRunTimeParamInfoData(moduleInstance->S,
    0);
  st.tls = moduleInstance->emlrtRootTLSGlobal;
  emlrtLicenseCheckR2022a(&st, "EMLRT:runTime:MexFunctionNeedsLicense",
    "communication_toolbox", 2);
  cgxertSetGcb(moduleInstance->S, -1, -1);
  mw__internal__call__reset(moduleInstance, &st, *SamplesPerSymbol,
    *DampingFactor, *NormalizedLoopBandwidth);
  cgxertRestoreGcb(moduleInstance->S, -1, -1);
}

static void cgxe_mdl_outputs(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  real_T *DampingFactor;
  real_T *NormalizedLoopBandwidth;
  real_T *SamplesPerSymbol;
  NormalizedLoopBandwidth = (real_T *)cgxertGetRunTimeParamInfoData
    (moduleInstance->S, 2);
  DampingFactor = (real_T *)cgxertGetRunTimeParamInfoData(moduleInstance->S, 1);
  SamplesPerSymbol = (real_T *)cgxertGetRunTimeParamInfoData(moduleInstance->S,
    0);
  st.tls = moduleInstance->emlrtRootTLSGlobal;
  cgxertSetGcb(moduleInstance->S, -1, -1);
  mw__internal__call__step(moduleInstance, &st, *SamplesPerSymbol,
    *DampingFactor, *NormalizedLoopBandwidth, *moduleInstance->u0,
    moduleInstance->b_y0, moduleInstance->b_y1);
  cgxertRestoreGcb(moduleInstance->S, -1, -1);
}

static void cgxe_mdl_update(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance)
{
  (void)moduleInstance;
}

static void cgxe_mdl_derivative(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance)
{
  (void)moduleInstance;
}

static void cgxe_mdl_enable(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance)
{
  (void)moduleInstance;
}

static void cgxe_mdl_disable(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance)
{
  (void)moduleInstance;
}

static void cgxe_mdl_terminate(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance)
{
  cgxertSetGcb(moduleInstance->S, -1, -1);
  cgxertRestoreGcb(moduleInstance->S, -1, -1);
}

static void mw__internal__call__setup(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp, real_T SamplesPerSymbol, real_T
  DampingFactor, real_T NormalizedLoopBandwidth)
{
  static const int32_T iv[2] = { 1, 51 };

  static const int32_T iv1[2] = { 1, 51 };

  static const int32_T iv2[2] = { 1, 5 };

  static char_T b_u[51] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 's', 'y', 's',
    't', 'e', 'm', ':', 'm', 'e', 't', 'h', 'o', 'd', 'C', 'a', 'l', 'l', 'e',
    'd', 'W', 'h', 'e', 'n', 'L', 'o', 'c', 'k', 'e', 'd', 'R', 'e', 'l', 'e',
    'a', 's', 'e', 'd', 'C', 'o', 'd', 'e', 'g', 'e', 'n' };

  static char_T d_u[5] = { 's', 'e', 't', 'u', 'p' };

  static char_T correctedValue[4] = { 'A', 'u', 't', 'o' };

  cell_wrap varSizes[1];
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *m;
  const mxArray *y;
  int32_T i;
  char_T u[51];
  char_T c_u[5];
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (!moduleInstance->sysobj_not_empty) {
    st.site = &f_emlrtRSI;
    moduleInstance->sysobj.CustomPhaseOffset = 0.0;
    b_st.site = &emlrtRSI;
    c_st.site = &b_emlrtRSI;
    d_st.site = &c_emlrtRSI;
    e_st.site = &d_emlrtRSI;
    d_st.site = &c_emlrtRSI;
    moduleInstance->sysobj.TunablePropsChanged = false;
    e_st.site = &e_emlrtRSI;
    moduleInstance->sysobj.isInitialized = 0;
    moduleInstance->sysobj_not_empty = true;
    st.site = &g_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    c_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    for (i = 0; i < 4; i++) {
      moduleInstance->sysobj.ModulationPhaseOffset[i] = correctedValue[i];
    }

    st.site = &h_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &h_emlrtRSI;
    CarrierSynchronizer_set_SamplesPerSymbol(&st, &moduleInstance->sysobj,
      SamplesPerSymbol);
    st.site = &i_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &i_emlrtRSI;
    CarrierSynchronizer_set_DampingFactor(&st, &moduleInstance->sysobj,
      DampingFactor);
    st.site = &j_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &j_emlrtRSI;
    CarrierSynchronizer_set_NormalizedLoopBandwidth(&st, &moduleInstance->sysobj,
      NormalizedLoopBandwidth);
  }

  st.site = &k_emlrtRSI;
  if (moduleInstance->sysobj.isInitialized != 0) {
    for (i = 0; i < 51; i++) {
      u[i] = b_u[i];
    }

    y = NULL;
    m = emlrtCreateCharArray(2, &iv[0]);
    emlrtInitCharArrayR2013a(&st, 51, m, &u[0]);
    emlrtAssign(&y, m);
    for (i = 0; i < 51; i++) {
      u[i] = b_u[i];
    }

    b_y = NULL;
    m = emlrtCreateCharArray(2, &iv1[0]);
    emlrtInitCharArrayR2013a(&st, 51, m, &u[0]);
    emlrtAssign(&b_y, m);
    for (i = 0; i < 5; i++) {
      c_u[i] = d_u[i];
    }

    c_y = NULL;
    m = emlrtCreateCharArray(2, &iv2[0]);
    emlrtInitCharArrayR2013a(&st, 5, m, &c_u[0]);
    emlrtAssign(&c_y, m);
    b_st.site = &e_emlrtRSI;
    error(&b_st, y, getString(&b_st, message(&b_st, b_y, c_y, &g_emlrtMCI),
           &g_emlrtMCI), &g_emlrtMCI);
  }

  moduleInstance->sysobj.isInitialized = 1;
  b_st.site = &e_emlrtRSI;
  for (i = 0; i < 8; i++) {
    varSizes[0].f1[i] = 1U;
  }

  moduleInstance->sysobj.inputVarSize[0] = varSizes[0];
  b_st.site = &e_emlrtRSI;
  CarrierSynchronizer_setupImpl(&moduleInstance->sysobj);
  b_st.site = &e_emlrtRSI;
  SystemCore_checkTunablePropChange(&b_st, &moduleInstance->sysobj);
  moduleInstance->sysobj.TunablePropsChanged = false;
}

static void CarrierSynchronizer_set_SamplesPerSymbol(const emlrtStack *sp,
  comm_CarrierSynchronizer *obj, real_T b_value)
{
  static const int32_T iv[2] = { 1, 23 };

  static const int32_T iv1[2] = { 1, 21 };

  static const int32_T iv10[2] = { 1, 16 };

  static const int32_T iv11[2] = { 1, 16 };

  static const int32_T iv2[2] = { 1, 48 };

  static const int32_T iv3[2] = { 1, 21 };

  static const int32_T iv4[2] = { 1, 46 };

  static const int32_T iv5[2] = { 1, 16 };

  static const int32_T iv6[2] = { 1, 22 };

  static const int32_T iv7[2] = { 1, 46 };

  static const int32_T iv8[2] = { 1, 16 };

  static const int32_T iv9[2] = { 1, 47 };

  static char_T f_u[48] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'P', 'o', 's', 'i', 't', 'i', 'v', 'e' };

  static char_T p_u[47] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'I', 'n', 't', 'e', 'g', 'e', 'r' };

  static char_T j_u[46] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'F', 'i', 'n', 'i', 't', 'e' };

  static char_T n_u[46] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'N', 'o', 'n', 'N', 'a', 'N' };

  static char_T b_u[23] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'P', 'o', 's', 'i', 't', 'i', 'v', 'e' };

  static char_T m_u[22] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'I', 'n', 't', 'e', 'g', 'e', 'r' };

  static char_T e_u[21] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'F', 'i', 'n', 'i', 't', 'e' };

  static char_T i_u[21] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'N', 'o', 'n', 'N', 'a', 'N' };

  static char_T k_u[16] = { 'S', 'a', 'm', 'p', 'l', 'e', 's', 'P', 'e', 'r',
    'S', 'y', 'm', 'b', 'o', 'l' };

  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *d_y;
  const mxArray *e_y;
  const mxArray *f_y;
  const mxArray *g_y;
  const mxArray *h_y;
  const mxArray *i_y;
  const mxArray *j_y;
  const mxArray *k_y;
  const mxArray *l_y;
  const mxArray *m;
  const mxArray *y;
  int32_T i;
  char_T d_u[48];
  char_T o_u[47];
  char_T g_u[46];
  char_T u[23];
  char_T l_u[22];
  char_T c_u[21];
  char_T h_u[16];
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &l_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_st.site = &m_emlrtRSI;
  p = true;
  if (b_value <= 0.0) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 23; i++) {
      u[i] = b_u[i];
    }

    y = NULL;
    m = emlrtCreateCharArray(2, &iv[0]);
    emlrtInitCharArrayR2013a(&b_st, 23, m, &u[0]);
    emlrtAssign(&y, m);
    for (i = 0; i < 48; i++) {
      d_u[i] = f_u[i];
    }

    c_y = NULL;
    m = emlrtCreateCharArray(2, &iv2[0]);
    emlrtInitCharArrayR2013a(&b_st, 48, m, &d_u[0]);
    emlrtAssign(&c_y, m);
    for (i = 0; i < 16; i++) {
      h_u[i] = k_u[i];
    }

    f_y = NULL;
    m = emlrtCreateCharArray(2, &iv5[0]);
    emlrtInitCharArrayR2013a(&b_st, 16, m, &h_u[0]);
    emlrtAssign(&f_y, m);
    c_st.site = &fb_emlrtRSI;
    error(&c_st, y, getString(&c_st, message(&c_st, c_y, f_y, &emlrtMCI),
           &emlrtMCI), &emlrtMCI);
  }

  b_st.site = &m_emlrtRSI;
  p = true;
  if ((!!muDoubleScalarIsInf(b_value)) || (!!muDoubleScalarIsNaN(b_value))) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 21; i++) {
      c_u[i] = e_u[i];
    }

    b_y = NULL;
    m = emlrtCreateCharArray(2, &iv1[0]);
    emlrtInitCharArrayR2013a(&b_st, 21, m, &c_u[0]);
    emlrtAssign(&b_y, m);
    for (i = 0; i < 46; i++) {
      g_u[i] = j_u[i];
    }

    e_y = NULL;
    m = emlrtCreateCharArray(2, &iv4[0]);
    emlrtInitCharArrayR2013a(&b_st, 46, m, &g_u[0]);
    emlrtAssign(&e_y, m);
    for (i = 0; i < 16; i++) {
      h_u[i] = k_u[i];
    }

    i_y = NULL;
    m = emlrtCreateCharArray(2, &iv8[0]);
    emlrtInitCharArrayR2013a(&b_st, 16, m, &h_u[0]);
    emlrtAssign(&i_y, m);
    c_st.site = &eb_emlrtRSI;
    error(&c_st, b_y, getString(&c_st, message(&c_st, e_y, i_y, &b_emlrtMCI),
           &b_emlrtMCI), &b_emlrtMCI);
  }

  b_st.site = &m_emlrtRSI;
  p = true;
  if (muDoubleScalarIsNaN(b_value)) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 21; i++) {
      c_u[i] = i_u[i];
    }

    d_y = NULL;
    m = emlrtCreateCharArray(2, &iv3[0]);
    emlrtInitCharArrayR2013a(&b_st, 21, m, &c_u[0]);
    emlrtAssign(&d_y, m);
    for (i = 0; i < 46; i++) {
      g_u[i] = n_u[i];
    }

    h_y = NULL;
    m = emlrtCreateCharArray(2, &iv7[0]);
    emlrtInitCharArrayR2013a(&b_st, 46, m, &g_u[0]);
    emlrtAssign(&h_y, m);
    for (i = 0; i < 16; i++) {
      h_u[i] = k_u[i];
    }

    k_y = NULL;
    m = emlrtCreateCharArray(2, &iv10[0]);
    emlrtInitCharArrayR2013a(&b_st, 16, m, &h_u[0]);
    emlrtAssign(&k_y, m);
    c_st.site = &db_emlrtRSI;
    error(&c_st, d_y, getString(&c_st, message(&c_st, h_y, k_y, &c_emlrtMCI),
           &c_emlrtMCI), &c_emlrtMCI);
  }

  b_st.site = &m_emlrtRSI;
  p = true;
  if ((!muDoubleScalarIsInf(b_value)) && (!muDoubleScalarIsNaN(b_value)) &&
      (muDoubleScalarFloor(b_value) == b_value)) {
  } else {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 22; i++) {
      l_u[i] = m_u[i];
    }

    g_y = NULL;
    m = emlrtCreateCharArray(2, &iv6[0]);
    emlrtInitCharArrayR2013a(&b_st, 22, m, &l_u[0]);
    emlrtAssign(&g_y, m);
    for (i = 0; i < 47; i++) {
      o_u[i] = p_u[i];
    }

    j_y = NULL;
    m = emlrtCreateCharArray(2, &iv9[0]);
    emlrtInitCharArrayR2013a(&b_st, 47, m, &o_u[0]);
    emlrtAssign(&j_y, m);
    for (i = 0; i < 16; i++) {
      h_u[i] = k_u[i];
    }

    l_y = NULL;
    m = emlrtCreateCharArray(2, &iv11[0]);
    emlrtInitCharArrayR2013a(&b_st, 16, m, &h_u[0]);
    emlrtAssign(&l_y, m);
    c_st.site = &gb_emlrtRSI;
    error(&c_st, g_y, getString(&c_st, message(&c_st, j_y, l_y, &d_emlrtMCI),
           &d_emlrtMCI), &d_emlrtMCI);
  }

  obj->SamplesPerSymbol = b_value;
}

static void CarrierSynchronizer_set_DampingFactor(const emlrtStack *sp,
  comm_CarrierSynchronizer *obj, real_T b_value)
{
  static const int32_T iv[2] = { 1, 23 };

  static const int32_T iv1[2] = { 1, 21 };

  static const int32_T iv2[2] = { 1, 48 };

  static const int32_T iv3[2] = { 1, 21 };

  static const int32_T iv4[2] = { 1, 46 };

  static const int32_T iv5[2] = { 1, 13 };

  static const int32_T iv6[2] = { 1, 46 };

  static const int32_T iv7[2] = { 1, 13 };

  static const int32_T iv8[2] = { 1, 13 };

  static char_T f_u[48] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'P', 'o', 's', 'i', 't', 'i', 'v', 'e' };

  static char_T j_u[46] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'F', 'i', 'n', 'i', 't', 'e' };

  static char_T l_u[46] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'N', 'o', 'n', 'N', 'a', 'N' };

  static char_T b_u[23] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'P', 'o', 's', 'i', 't', 'i', 'v', 'e' };

  static char_T e_u[21] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'F', 'i', 'n', 'i', 't', 'e' };

  static char_T i_u[21] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'N', 'o', 'n', 'N', 'a', 'N' };

  static char_T k_u[13] = { 'D', 'a', 'm', 'p', 'i', 'n', 'g', 'F', 'a', 'c',
    't', 'o', 'r' };

  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *d_y;
  const mxArray *e_y;
  const mxArray *f_y;
  const mxArray *g_y;
  const mxArray *h_y;
  const mxArray *i_y;
  const mxArray *m;
  const mxArray *y;
  int32_T i;
  char_T d_u[48];
  char_T g_u[46];
  char_T u[23];
  char_T c_u[21];
  char_T h_u[13];
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &n_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_st.site = &m_emlrtRSI;
  p = true;
  if (b_value <= 0.0) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 23; i++) {
      u[i] = b_u[i];
    }

    y = NULL;
    m = emlrtCreateCharArray(2, &iv[0]);
    emlrtInitCharArrayR2013a(&b_st, 23, m, &u[0]);
    emlrtAssign(&y, m);
    for (i = 0; i < 48; i++) {
      d_u[i] = f_u[i];
    }

    c_y = NULL;
    m = emlrtCreateCharArray(2, &iv2[0]);
    emlrtInitCharArrayR2013a(&b_st, 48, m, &d_u[0]);
    emlrtAssign(&c_y, m);
    for (i = 0; i < 13; i++) {
      h_u[i] = k_u[i];
    }

    f_y = NULL;
    m = emlrtCreateCharArray(2, &iv5[0]);
    emlrtInitCharArrayR2013a(&b_st, 13, m, &h_u[0]);
    emlrtAssign(&f_y, m);
    c_st.site = &fb_emlrtRSI;
    error(&c_st, y, getString(&c_st, message(&c_st, c_y, f_y, &emlrtMCI),
           &emlrtMCI), &emlrtMCI);
  }

  b_st.site = &m_emlrtRSI;
  p = true;
  if ((!!muDoubleScalarIsInf(b_value)) || (!!muDoubleScalarIsNaN(b_value))) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 21; i++) {
      c_u[i] = e_u[i];
    }

    b_y = NULL;
    m = emlrtCreateCharArray(2, &iv1[0]);
    emlrtInitCharArrayR2013a(&b_st, 21, m, &c_u[0]);
    emlrtAssign(&b_y, m);
    for (i = 0; i < 46; i++) {
      g_u[i] = j_u[i];
    }

    e_y = NULL;
    m = emlrtCreateCharArray(2, &iv4[0]);
    emlrtInitCharArrayR2013a(&b_st, 46, m, &g_u[0]);
    emlrtAssign(&e_y, m);
    for (i = 0; i < 13; i++) {
      h_u[i] = k_u[i];
    }

    h_y = NULL;
    m = emlrtCreateCharArray(2, &iv7[0]);
    emlrtInitCharArrayR2013a(&b_st, 13, m, &h_u[0]);
    emlrtAssign(&h_y, m);
    c_st.site = &eb_emlrtRSI;
    error(&c_st, b_y, getString(&c_st, message(&c_st, e_y, h_y, &b_emlrtMCI),
           &b_emlrtMCI), &b_emlrtMCI);
  }

  b_st.site = &m_emlrtRSI;
  p = true;
  if (muDoubleScalarIsNaN(b_value)) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 21; i++) {
      c_u[i] = i_u[i];
    }

    d_y = NULL;
    m = emlrtCreateCharArray(2, &iv3[0]);
    emlrtInitCharArrayR2013a(&b_st, 21, m, &c_u[0]);
    emlrtAssign(&d_y, m);
    for (i = 0; i < 46; i++) {
      g_u[i] = l_u[i];
    }

    g_y = NULL;
    m = emlrtCreateCharArray(2, &iv6[0]);
    emlrtInitCharArrayR2013a(&b_st, 46, m, &g_u[0]);
    emlrtAssign(&g_y, m);
    for (i = 0; i < 13; i++) {
      h_u[i] = k_u[i];
    }

    i_y = NULL;
    m = emlrtCreateCharArray(2, &iv8[0]);
    emlrtInitCharArrayR2013a(&b_st, 13, m, &h_u[0]);
    emlrtAssign(&i_y, m);
    c_st.site = &db_emlrtRSI;
    error(&c_st, d_y, getString(&c_st, message(&c_st, g_y, i_y, &c_emlrtMCI),
           &c_emlrtMCI), &c_emlrtMCI);
  }

  obj->DampingFactor = b_value;
}

static void CarrierSynchronizer_set_NormalizedLoopBandwidth(const emlrtStack *sp,
  comm_CarrierSynchronizer *obj, real_T b_value)
{
  static const int32_T iv[2] = { 1, 17 };

  static const int32_T iv1[2] = { 1, 19 };

  static const int32_T iv10[2] = { 1, 46 };

  static const int32_T iv11[2] = { 1, 23 };

  static const int32_T iv12[2] = { 1, 2 };

  static const int32_T iv13[2] = { 1, 46 };

  static const int32_T iv14[2] = { 1, 23 };

  static const int32_T iv15[2] = { 1, 23 };

  static const int32_T iv2[2] = { 1, 40 };

  static const int32_T iv3[2] = { 1, 23 };

  static const int32_T iv4[2] = { 1, 40 };

  static const int32_T iv5[2] = { 1, 23 };

  static const int32_T iv6[2] = { 1, 21 };

  static const int32_T iv7[2] = { 1, 48 };

  static const int32_T iv8[2] = { 1, 23 };

  static const int32_T iv9[2] = { 1, 21 };

  static char_T m_u[48] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'P', 'o', 's', 'i', 't', 'i', 'v', 'e' };

  static char_T q_u[46] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'F', 'i', 'n', 'i', 't', 'e' };

  static char_T s_u[46] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'V', 'a', 'l', 'i', 'd', 'a', 't', 'e', 'a', 't', 't',
    'r', 'i', 'b', 'u', 't', 'e', 's', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd',
    'N', 'o', 'n', 'N', 'a', 'N' };

  static char_T f_u[40] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'v', 'a', 'l',
    'i', 'd', 'a', 't', 'e', 'a', 't', 't', 'r', 'i', 'b', 'u', 't', 'e', 's',
    ':', 'e', 'x', 'p', 'e', 'c', 't', 'e', 'd', 'S', 'c', 'a', 'l', 'a', 'r' };

  static char_T h_u[23] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'P', 'o', 's', 'i', 't', 'i', 'v', 'e' };

  static char_T i_u[23] = { 'N', 'o', 'r', 'm', 'a', 'l', 'i', 'z', 'e', 'd',
    'L', 'o', 'o', 'p', 'B', 'a', 'n', 'd', 'w', 'i', 'd', 't', 'h' };

  static char_T l_u[21] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'F', 'i', 'n', 'i', 't', 'e' };

  static char_T o_u[21] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'e', 'x', 'p',
    'e', 'c', 't', 'e', 'd', 'N', 'o', 'n', 'N', 'a', 'N' };

  static char_T e_u[19] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'n', 'o', 't',
    'L', 'e', 's', 's', 'E', 'q', 'u', 'a', 'l' };

  static char_T b_u[17] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 'n', 'o', 't',
    'G', 'r', 'e', 'a', 't', 'e', 'r' };

  static char_T r_u[2] = { '<', '=' };

  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *d_y;
  const mxArray *e_y;
  const mxArray *f_y;
  const mxArray *g_y;
  const mxArray *h_y;
  const mxArray *i_y;
  const mxArray *j_y;
  const mxArray *k_y;
  const mxArray *l_y;
  const mxArray *m;
  const mxArray *m_y;
  const mxArray *n_y;
  const mxArray *o_y;
  const mxArray *p_y;
  const mxArray *q_y;
  const mxArray *r_y;
  const mxArray *s_y;
  const mxArray *y;
  int32_T i;
  char_T k_u[48];
  char_T n_u[46];
  char_T d_u[40];
  char_T g_u[23];
  char_T j_u[21];
  char_T c_u[19];
  char_T u[17];
  char_T p_u[2];
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &o_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_st.site = &m_emlrtRSI;
  p = true;
  if (!(b_value > 0.0)) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 17; i++) {
      u[i] = b_u[i];
    }

    y = NULL;
    m = emlrtCreateCharArray(2, &iv[0]);
    emlrtInitCharArrayR2013a(&b_st, 17, m, &u[0]);
    emlrtAssign(&y, m);
    for (i = 0; i < 40; i++) {
      d_u[i] = f_u[i];
    }

    c_y = NULL;
    m = emlrtCreateCharArray(2, &iv2[0]);
    emlrtInitCharArrayR2013a(&b_st, 40, m, &d_u[0]);
    emlrtAssign(&c_y, m);
    for (i = 0; i < 23; i++) {
      g_u[i] = i_u[i];
    }

    f_y = NULL;
    m = emlrtCreateCharArray(2, &iv5[0]);
    emlrtInitCharArrayR2013a(&b_st, 23, m, &g_u[0]);
    emlrtAssign(&f_y, m);
    h_y = NULL;
    m = emlrtCreateString1R2022a(&b_st, '>');
    emlrtAssign(&h_y, m);
    k_y = NULL;
    m = emlrtCreateString1R2022a(&b_st, '0');
    emlrtAssign(&k_y, m);
    c_st.site = &ib_emlrtRSI;
    error(&c_st, y, getString(&c_st, b_message(&c_st, c_y, f_y, h_y, k_y,
            &e_emlrtMCI), &e_emlrtMCI), &e_emlrtMCI);
  }

  b_st.site = &m_emlrtRSI;
  p = true;
  if (!(b_value <= 1.0)) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 19; i++) {
      c_u[i] = e_u[i];
    }

    b_y = NULL;
    m = emlrtCreateCharArray(2, &iv1[0]);
    emlrtInitCharArrayR2013a(&b_st, 19, m, &c_u[0]);
    emlrtAssign(&b_y, m);
    for (i = 0; i < 40; i++) {
      d_u[i] = f_u[i];
    }

    e_y = NULL;
    m = emlrtCreateCharArray(2, &iv4[0]);
    emlrtInitCharArrayR2013a(&b_st, 40, m, &d_u[0]);
    emlrtAssign(&e_y, m);
    for (i = 0; i < 23; i++) {
      g_u[i] = i_u[i];
    }

    j_y = NULL;
    m = emlrtCreateCharArray(2, &iv8[0]);
    emlrtInitCharArrayR2013a(&b_st, 23, m, &g_u[0]);
    emlrtAssign(&j_y, m);
    for (i = 0; i < 2; i++) {
      p_u[i] = r_u[i];
    }

    o_y = NULL;
    m = emlrtCreateCharArray(2, &iv12[0]);
    emlrtInitCharArrayR2013a(&b_st, 2, m, &p_u[0]);
    emlrtAssign(&o_y, m);
    q_y = NULL;
    m = emlrtCreateString1R2022a(&b_st, '1');
    emlrtAssign(&q_y, m);
    c_st.site = &hb_emlrtRSI;
    error(&c_st, b_y, getString(&c_st, b_message(&c_st, e_y, j_y, o_y, q_y,
            &f_emlrtMCI), &f_emlrtMCI), &f_emlrtMCI);
  }

  b_st.site = &m_emlrtRSI;
  p = true;
  if (b_value <= 0.0) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 23; i++) {
      g_u[i] = h_u[i];
    }

    d_y = NULL;
    m = emlrtCreateCharArray(2, &iv3[0]);
    emlrtInitCharArrayR2013a(&b_st, 23, m, &g_u[0]);
    emlrtAssign(&d_y, m);
    for (i = 0; i < 48; i++) {
      k_u[i] = m_u[i];
    }

    i_y = NULL;
    m = emlrtCreateCharArray(2, &iv7[0]);
    emlrtInitCharArrayR2013a(&b_st, 48, m, &k_u[0]);
    emlrtAssign(&i_y, m);
    for (i = 0; i < 23; i++) {
      g_u[i] = i_u[i];
    }

    n_y = NULL;
    m = emlrtCreateCharArray(2, &iv11[0]);
    emlrtInitCharArrayR2013a(&b_st, 23, m, &g_u[0]);
    emlrtAssign(&n_y, m);
    c_st.site = &fb_emlrtRSI;
    error(&c_st, d_y, getString(&c_st, message(&c_st, i_y, n_y, &emlrtMCI),
           &emlrtMCI), &emlrtMCI);
  }

  b_st.site = &m_emlrtRSI;
  p = true;
  if ((!!muDoubleScalarIsInf(b_value)) || (!!muDoubleScalarIsNaN(b_value))) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 21; i++) {
      j_u[i] = l_u[i];
    }

    g_y = NULL;
    m = emlrtCreateCharArray(2, &iv6[0]);
    emlrtInitCharArrayR2013a(&b_st, 21, m, &j_u[0]);
    emlrtAssign(&g_y, m);
    for (i = 0; i < 46; i++) {
      n_u[i] = q_u[i];
    }

    m_y = NULL;
    m = emlrtCreateCharArray(2, &iv10[0]);
    emlrtInitCharArrayR2013a(&b_st, 46, m, &n_u[0]);
    emlrtAssign(&m_y, m);
    for (i = 0; i < 23; i++) {
      g_u[i] = i_u[i];
    }

    r_y = NULL;
    m = emlrtCreateCharArray(2, &iv14[0]);
    emlrtInitCharArrayR2013a(&b_st, 23, m, &g_u[0]);
    emlrtAssign(&r_y, m);
    c_st.site = &eb_emlrtRSI;
    error(&c_st, g_y, getString(&c_st, message(&c_st, m_y, r_y, &b_emlrtMCI),
           &b_emlrtMCI), &b_emlrtMCI);
  }

  b_st.site = &m_emlrtRSI;
  p = true;
  if (muDoubleScalarIsNaN(b_value)) {
    p = false;
  }

  if (!p) {
    for (i = 0; i < 21; i++) {
      j_u[i] = o_u[i];
    }

    l_y = NULL;
    m = emlrtCreateCharArray(2, &iv9[0]);
    emlrtInitCharArrayR2013a(&b_st, 21, m, &j_u[0]);
    emlrtAssign(&l_y, m);
    for (i = 0; i < 46; i++) {
      n_u[i] = s_u[i];
    }

    p_y = NULL;
    m = emlrtCreateCharArray(2, &iv13[0]);
    emlrtInitCharArrayR2013a(&b_st, 46, m, &n_u[0]);
    emlrtAssign(&p_y, m);
    for (i = 0; i < 23; i++) {
      g_u[i] = i_u[i];
    }

    s_y = NULL;
    m = emlrtCreateCharArray(2, &iv15[0]);
    emlrtInitCharArrayR2013a(&b_st, 23, m, &g_u[0]);
    emlrtAssign(&s_y, m);
    c_st.site = &db_emlrtRSI;
    error(&c_st, l_y, getString(&c_st, message(&c_st, p_y, s_y, &c_emlrtMCI),
           &c_emlrtMCI), &c_emlrtMCI);
  }

  obj->NormalizedLoopBandwidth = b_value;
}

static void CarrierSynchronizer_setupImpl(comm_CarrierSynchronizer *obj)
{
  emlrtStack st;
  real_T PhaseRecoveryGain;
  real_T PhaseRecoveryLoopBandwidth;
  real_T d;
  obj->pPhase = 0.0;
  obj->pPreviousSample.re = 0.0;
  obj->pPreviousSample.im = 0.0;
  st.site = &p_emlrtRSI;
  PhaseRecoveryLoopBandwidth = obj->NormalizedLoopBandwidth *
    obj->SamplesPerSymbol;
  PhaseRecoveryGain = obj->SamplesPerSymbol;
  PhaseRecoveryLoopBandwidth /= (obj->DampingFactor + 0.25 / obj->DampingFactor)
    * obj->SamplesPerSymbol;
  d = (2.0 * obj->DampingFactor * PhaseRecoveryLoopBandwidth + 1.0) +
    PhaseRecoveryLoopBandwidth * PhaseRecoveryLoopBandwidth;
  obj->pProportionalGain = 4.0 * obj->DampingFactor * PhaseRecoveryLoopBandwidth
    / d / (2.0 * PhaseRecoveryGain);
  obj->pIntegratorGain = 4.0 * PhaseRecoveryLoopBandwidth *
    PhaseRecoveryLoopBandwidth / d / (2.0 * PhaseRecoveryGain);
  if (b_strcmp(obj->ModulationPhaseOffset)) {
    obj->pActualPhaseOffset = 0.0;
  } else {
    obj->pActualPhaseOffset = obj->CustomPhaseOffset;
  }

  obj->pDigitalSynthesizerGain = -1.0;
}

static boolean_T b_strcmp(char_T a[4])
{
  static char_T b_b[4] = { 'A', 'u', 't', 'o' };

  int32_T ret;
  char_T b[4];
  for (ret = 0; ret < 4; ret++) {
    b[ret] = b_b[ret];
  }

  ret = memcmp(&a[0], &b[0], 4);
  return ret == 0;
}

static void SystemCore_checkTunablePropChange(const emlrtStack *sp,
  comm_CarrierSynchronizer *obj)
{
  static const int32_T iv[2] = { 1, 44 };

  static const int32_T iv1[2] = { 1, 44 };

  static char_T b_u[44] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 's', 'y', 's',
    't', 'e', 'm', ':', 'i', 'n', 'v', 'a', 'l', 'i', 'd', 'T', 'u', 'n', 'a',
    'b', 'l', 'e', 'M', 'o', 'd', 'A', 'c', 'c', 'e', 's', 's', 'C', 'o', 'd',
    'e', 'g', 'e', 'n' };

  emlrtStack st;
  const mxArray *b_y;
  const mxArray *m;
  const mxArray *y;
  int32_T i;
  char_T u[44];
  st.prev = sp;
  st.tls = sp->tls;
  if (obj->TunablePropsChanged) {
    for (i = 0; i < 44; i++) {
      u[i] = b_u[i];
    }

    y = NULL;
    m = emlrtCreateCharArray(2, &iv[0]);
    emlrtInitCharArrayR2013a((emlrtConstCTX)sp, 44, m, &u[0]);
    emlrtAssign(&y, m);
    for (i = 0; i < 44; i++) {
      u[i] = b_u[i];
    }

    b_y = NULL;
    m = emlrtCreateCharArray(2, &iv1[0]);
    emlrtInitCharArrayR2013a((emlrtConstCTX)sp, 44, m, &u[0]);
    emlrtAssign(&b_y, m);
    st.site = &e_emlrtRSI;
    error(&st, y, getString(&st, c_message(&st, b_y, &g_emlrtMCI), &g_emlrtMCI),
          &g_emlrtMCI);
  }
}

static void mw__internal__call__reset(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp, real_T SamplesPerSymbol, real_T
  DampingFactor, real_T NormalizedLoopBandwidth)
{
  static const int32_T iv[2] = { 1, 45 };

  static const int32_T iv1[2] = { 1, 45 };

  static const int32_T iv2[2] = { 1, 5 };

  static char_T b_u[45] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 's', 'y', 's',
    't', 'e', 'm', ':', 'm', 'e', 't', 'h', 'o', 'd', 'C', 'a', 'l', 'l', 'e',
    'd', 'W', 'h', 'e', 'n', 'R', 'e', 'l', 'e', 'a', 's', 'e', 'd', 'C', 'o',
    'd', 'e', 'g', 'e', 'n' };

  static char_T d_u[5] = { 'r', 'e', 's', 'e', 't' };

  static char_T correctedValue[4] = { 'A', 'u', 't', 'o' };

  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *m;
  const mxArray *y;
  int32_T i;
  char_T u[45];
  char_T c_u[5];
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (!moduleInstance->sysobj_not_empty) {
    st.site = &f_emlrtRSI;
    moduleInstance->sysobj.CustomPhaseOffset = 0.0;
    b_st.site = &emlrtRSI;
    c_st.site = &b_emlrtRSI;
    d_st.site = &c_emlrtRSI;
    e_st.site = &d_emlrtRSI;
    d_st.site = &c_emlrtRSI;
    moduleInstance->sysobj.TunablePropsChanged = false;
    e_st.site = &e_emlrtRSI;
    moduleInstance->sysobj.isInitialized = 0;
    moduleInstance->sysobj_not_empty = true;
    st.site = &g_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    c_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    for (i = 0; i < 4; i++) {
      moduleInstance->sysobj.ModulationPhaseOffset[i] = correctedValue[i];
    }

    st.site = &h_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &h_emlrtRSI;
    CarrierSynchronizer_set_SamplesPerSymbol(&st, &moduleInstance->sysobj,
      SamplesPerSymbol);
    st.site = &i_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &i_emlrtRSI;
    CarrierSynchronizer_set_DampingFactor(&st, &moduleInstance->sysobj,
      DampingFactor);
    st.site = &j_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &j_emlrtRSI;
    CarrierSynchronizer_set_NormalizedLoopBandwidth(&st, &moduleInstance->sysobj,
      NormalizedLoopBandwidth);
  }

  st.site = &q_emlrtRSI;
  if (moduleInstance->sysobj.isInitialized == 2) {
    for (i = 0; i < 45; i++) {
      u[i] = b_u[i];
    }

    y = NULL;
    m = emlrtCreateCharArray(2, &iv[0]);
    emlrtInitCharArrayR2013a(&st, 45, m, &u[0]);
    emlrtAssign(&y, m);
    for (i = 0; i < 45; i++) {
      u[i] = b_u[i];
    }

    b_y = NULL;
    m = emlrtCreateCharArray(2, &iv1[0]);
    emlrtInitCharArrayR2013a(&st, 45, m, &u[0]);
    emlrtAssign(&b_y, m);
    for (i = 0; i < 5; i++) {
      c_u[i] = d_u[i];
    }

    c_y = NULL;
    m = emlrtCreateCharArray(2, &iv2[0]);
    emlrtInitCharArrayR2013a(&st, 5, m, &c_u[0]);
    emlrtAssign(&c_y, m);
    b_st.site = &e_emlrtRSI;
    error(&b_st, y, getString(&b_st, message(&b_st, b_y, c_y, &g_emlrtMCI),
           &g_emlrtMCI), &g_emlrtMCI);
  }

  if (moduleInstance->sysobj.isInitialized == 1) {
    b_st.site = &e_emlrtRSI;
    moduleInstance->sysobj.pLoopFilterState = 0.0;
    moduleInstance->sysobj.pIntegFilterState = 0.0;
    moduleInstance->sysobj.pDDSPreviousInput = 0.0;
    moduleInstance->sysobj.pPhase = 0.0;
    moduleInstance->sysobj.pPreviousSample.re = 0.0;
    moduleInstance->sysobj.pPreviousSample.im = 0.0;
  }
}

static void mw__internal__call__step(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp, real_T SamplesPerSymbol, real_T
  DampingFactor, real_T NormalizedLoopBandwidth, creal_T b_u0, creal_T *c_y0,
  real_T *c_y1)
{
  static const int32_T iv[2] = { 1, 51 };

  static const int32_T iv1[2] = { 1, 51 };

  static const int32_T iv2[2] = { 1, 5 };

  static char_T b_u[51] = { 'M', 'A', 'T', 'L', 'A', 'B', ':', 's', 'y', 's',
    't', 'e', 'm', ':', 'm', 'e', 't', 'h', 'o', 'd', 'C', 'a', 'l', 'l', 'e',
    'd', 'W', 'h', 'e', 'n', 'L', 'o', 'c', 'k', 'e', 'd', 'R', 'e', 'l', 'e',
    'a', 's', 'e', 'd', 'C', 'o', 'd', 'e', 'g', 'e', 'n' };

  static char_T d_u[5] = { 's', 'e', 't', 'u', 'p' };

  static char_T correctedValue[4] = { 'A', 'u', 't', 'o' };

  cell_wrap varSizes[1];
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *m;
  const mxArray *y;
  real_T DDSOut;
  real_T d;
  real_T loopFiltOut;
  real_T phErr;
  real_T phase;
  real_T previousSample_im;
  real_T previousSample_re;
  real_T re;
  real_T theta;
  int32_T k;
  char_T u[51];
  char_T c_u[5];
  boolean_T exitg1;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  if (!moduleInstance->sysobj_not_empty) {
    st.site = &f_emlrtRSI;
    moduleInstance->sysobj.CustomPhaseOffset = 0.0;
    b_st.site = &emlrtRSI;
    c_st.site = &b_emlrtRSI;
    d_st.site = &c_emlrtRSI;
    e_st.site = &d_emlrtRSI;
    d_st.site = &c_emlrtRSI;
    moduleInstance->sysobj.TunablePropsChanged = false;
    e_st.site = &e_emlrtRSI;
    moduleInstance->sysobj.isInitialized = 0;
    moduleInstance->sysobj_not_empty = true;
    st.site = &g_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    c_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    for (k = 0; k < 4; k++) {
      moduleInstance->sysobj.ModulationPhaseOffset[k] = correctedValue[k];
    }

    st.site = &h_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &h_emlrtRSI;
    CarrierSynchronizer_set_SamplesPerSymbol(&st, &moduleInstance->sysobj,
      SamplesPerSymbol);
    st.site = &i_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &i_emlrtRSI;
    CarrierSynchronizer_set_DampingFactor(&st, &moduleInstance->sysobj,
      DampingFactor);
    st.site = &j_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &j_emlrtRSI;
    CarrierSynchronizer_set_NormalizedLoopBandwidth(&st, &moduleInstance->sysobj,
      NormalizedLoopBandwidth);
  }

  if (moduleInstance->sysobj.SamplesPerSymbol != SamplesPerSymbol) {
    st.site = &r_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &r_emlrtRSI;
    CarrierSynchronizer_set_SamplesPerSymbol(&st, &moduleInstance->sysobj,
      SamplesPerSymbol);
  }

  if (moduleInstance->sysobj.DampingFactor != DampingFactor) {
    st.site = &s_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &s_emlrtRSI;
    CarrierSynchronizer_set_DampingFactor(&st, &moduleInstance->sysobj,
      DampingFactor);
  }

  if (moduleInstance->sysobj.NormalizedLoopBandwidth != NormalizedLoopBandwidth)
  {
    st.site = &t_emlrtRSI;
    b_st.site = &d_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized == 1) {
      moduleInstance->sysobj.TunablePropsChanged = true;
    }

    st.site = &t_emlrtRSI;
    CarrierSynchronizer_set_NormalizedLoopBandwidth(&st, &moduleInstance->sysobj,
      NormalizedLoopBandwidth);
  }

  st.site = &u_emlrtRSI;
  if (moduleInstance->sysobj.isInitialized != 1) {
    b_st.site = &e_emlrtRSI;
    c_st.site = &e_emlrtRSI;
    if (moduleInstance->sysobj.isInitialized != 0) {
      for (k = 0; k < 51; k++) {
        u[k] = b_u[k];
      }

      y = NULL;
      m = emlrtCreateCharArray(2, &iv[0]);
      emlrtInitCharArrayR2013a(&c_st, 51, m, &u[0]);
      emlrtAssign(&y, m);
      for (k = 0; k < 51; k++) {
        u[k] = b_u[k];
      }

      b_y = NULL;
      m = emlrtCreateCharArray(2, &iv1[0]);
      emlrtInitCharArrayR2013a(&c_st, 51, m, &u[0]);
      emlrtAssign(&b_y, m);
      for (k = 0; k < 5; k++) {
        c_u[k] = d_u[k];
      }

      c_y = NULL;
      m = emlrtCreateCharArray(2, &iv2[0]);
      emlrtInitCharArrayR2013a(&c_st, 5, m, &c_u[0]);
      emlrtAssign(&c_y, m);
      d_st.site = &e_emlrtRSI;
      error(&d_st, y, getString(&d_st, message(&d_st, b_y, c_y, &g_emlrtMCI),
             &g_emlrtMCI), &g_emlrtMCI);
    }

    moduleInstance->sysobj.isInitialized = 1;
    d_st.site = &e_emlrtRSI;
    for (k = 0; k < 8; k++) {
      varSizes[0].f1[k] = 1U;
    }

    moduleInstance->sysobj.inputVarSize[0] = varSizes[0];
    d_st.site = &e_emlrtRSI;
    CarrierSynchronizer_setupImpl(&moduleInstance->sysobj);
    d_st.site = &e_emlrtRSI;
    SystemCore_checkTunablePropChange(&d_st, &moduleInstance->sysobj);
    moduleInstance->sysobj.TunablePropsChanged = false;
    c_st.site = &e_emlrtRSI;
    moduleInstance->sysobj.pLoopFilterState = 0.0;
    moduleInstance->sysobj.pIntegFilterState = 0.0;
    moduleInstance->sysobj.pDDSPreviousInput = 0.0;
    moduleInstance->sysobj.pPhase = 0.0;
    moduleInstance->sysobj.pPreviousSample.re = 0.0;
    moduleInstance->sysobj.pPreviousSample.im = 0.0;
  }

  b_st.site = &e_emlrtRSI;
  if (moduleInstance->sysobj.TunablePropsChanged) {
    moduleInstance->sysobj.TunablePropsChanged = false;
    c_st.site = &e_emlrtRSI;
    d_st.site = &v_emlrtRSI;
    theta = moduleInstance->sysobj.NormalizedLoopBandwidth *
      moduleInstance->sysobj.SamplesPerSymbol /
      ((moduleInstance->sysobj.DampingFactor + 0.25 /
        moduleInstance->sysobj.DampingFactor) *
       moduleInstance->sysobj.SamplesPerSymbol);
    d = (2.0 * moduleInstance->sysobj.DampingFactor * theta + 1.0) + theta *
      theta;
    moduleInstance->sysobj.pProportionalGain = 4.0 *
      moduleInstance->sysobj.DampingFactor * theta / d / (2.0 *
      moduleInstance->sysobj.SamplesPerSymbol);
    moduleInstance->sysobj.pIntegratorGain = 4.0 * theta * theta / d / (2.0 *
      moduleInstance->sysobj.SamplesPerSymbol);
    if (b_strcmp(moduleInstance->sysobj.ModulationPhaseOffset)) {
      moduleInstance->sysobj.pActualPhaseOffset = 0.0;
    } else {
      moduleInstance->sysobj.pActualPhaseOffset =
        moduleInstance->sysobj.CustomPhaseOffset;
    }
  }

  b_st.site = &e_emlrtRSI;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 8)) {
    if (moduleInstance->sysobj.inputVarSize[0].f1[k] != 1U) {
      for (k = 0; k < 8; k++) {
        moduleInstance->sysobj.inputVarSize[0].f1[k] = 1U;
      }

      exitg1 = true;
    } else {
      k++;
    }
  }

  b_st.site = &e_emlrtRSI;
  c_st.site = &w_emlrtRSI;
  d_st.site = &y_emlrtRSI;
  e_st.site = &x_emlrtRSI;
  theta = signDouble(moduleInstance->sysobj.pPreviousSample.re);
  d_st.site = &ab_emlrtRSI;
  e_st.site = &x_emlrtRSI;
  d = signDouble(moduleInstance->sysobj.pPreviousSample.im);
  phErr = theta * moduleInstance->sysobj.pPreviousSample.im - d *
    moduleInstance->sysobj.pPreviousSample.re;
  d_st.site = &bb_emlrtRSI;
  theta = sin(moduleInstance->sysobj.pPhase);
  d = cos(moduleInstance->sysobj.pPhase);
  c_y0->re = b_u0.re * d - b_u0.im * theta;
  c_y0->im = b_u0.re * theta + b_u0.im * d;
  loopFiltOut = phErr * moduleInstance->sysobj.pIntegratorGain +
    moduleInstance->sysobj.pLoopFilterState;
  DDSOut = moduleInstance->sysobj.pDDSPreviousInput +
    moduleInstance->sysobj.pIntegFilterState;
  phase = moduleInstance->sysobj.pDigitalSynthesizerGain * DDSOut;
  previousSample_re = c_y0->re;
  previousSample_im = c_y0->im;
  d_st.site = &cb_emlrtRSI;
  theta = sin(moduleInstance->sysobj.pActualPhaseOffset);
  d = cos(moduleInstance->sysobj.pActualPhaseOffset);
  re = c_y0->re * d - c_y0->im * theta;
  theta = c_y0->re * theta + c_y0->im * d;
  c_y0->re = re;
  c_y0->im = theta;
  moduleInstance->sysobj.pLoopFilterState = loopFiltOut;
  moduleInstance->sysobj.pIntegFilterState = DDSOut;
  moduleInstance->sysobj.pDDSPreviousInput = phErr *
    moduleInstance->sysobj.pProportionalGain + loopFiltOut;
  moduleInstance->sysobj.pPreviousSample.re = previousSample_re;
  moduleInstance->sysobj.pPreviousSample.im = previousSample_im;
  moduleInstance->sysobj.pPhase = phase;
  b_st.site = &e_emlrtRSI;
  SystemCore_checkTunablePropChange(&b_st, &moduleInstance->sysobj);
  *c_y1 = -(phase + moduleInstance->sysobj.pActualPhaseOffset);
}

static const mxArray *emlrt_marshallOut(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp)
{
  static const int32_T iv1[2] = { 1, 8 };

  static const int32_T iv2[2] = { 1, 4 };

  static const char_T *sv[17] = { "isInitialized", "TunablePropsChanged",
    "inputVarSize", "ModulationPhaseOffset", "CustomPhaseOffset",
    "SamplesPerSymbol", "DampingFactor", "NormalizedLoopBandwidth",
    "pProportionalGain", "pIntegratorGain", "pDigitalSynthesizerGain", "pPhase",
    "pPreviousSample", "pActualPhaseOffset", "pLoopFilterState",
    "pIntegFilterState", "pDDSPreviousInput" };

  static const char_T *sv1[1] = { "f1" };

  const mxArray *b_y;
  const mxArray *c_y;
  const mxArray *d_y;
  const mxArray *e_y;
  const mxArray *f_y;
  const mxArray *g_y;
  const mxArray *h_y;
  const mxArray *i_y;
  const mxArray *j_y;
  const mxArray *k_y;
  const mxArray *l_y;
  const mxArray *m;
  const mxArray *m_y;
  const mxArray *n_y;
  const mxArray *o_y;
  const mxArray *p_y;
  const mxArray *q_y;
  const mxArray *r_y;
  const mxArray *s_y;
  const mxArray *t_y;
  const mxArray *u_y;
  const mxArray *y;
  creal_T *r;
  real_T u_im;
  int32_T iv[1];
  int32_T b_i;
  int32_T i;
  uint32_T u[8];
  uint32_T *pData;
  char_T b_u[4];
  y = NULL;
  emlrtAssign(&y, emlrtCreateCellMatrix(2, 1));
  b_y = NULL;
  emlrtAssign(&b_y, emlrtCreateStructMatrix(1, 1, 17, (const char_T **)&sv[0]));
  c_y = NULL;
  m = emlrtCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *(int32_T *)emlrtMxGetData(m) = moduleInstance->sysobj.isInitialized;
  emlrtAssign(&c_y, m);
  emlrtSetFieldR2017b(b_y, 0, "isInitialized", c_y, 0);
  d_y = NULL;
  m = emlrtCreateLogicalScalar(moduleInstance->sysobj.TunablePropsChanged);
  emlrtAssign(&d_y, m);
  emlrtSetFieldR2017b(b_y, 0, "TunablePropsChanged", d_y, 1);
  e_y = NULL;
  iv[0] = 1;
  emlrtAssign(&e_y, emlrtCreateStructArray(1, &iv[0], 1, (const char_T **)&sv1[0]));
  for (i = 0; i < 8; i++) {
    u[i] = moduleInstance->sysobj.inputVarSize[0].f1[i];
  }

  f_y = NULL;
  m = emlrtCreateNumericArray(2, (const void *)&iv1[0], mxUINT32_CLASS, mxREAL);
  pData = (uint32_T *)emlrtMxGetData(m);
  i = 0;
  for (b_i = 0; b_i < 8; b_i++) {
    pData[i] = u[b_i];
    i++;
  }

  emlrtAssign(&f_y, m);
  emlrtSetFieldR2017b(e_y, 0, "f1", f_y, 0);
  emlrtSetFieldR2017b(b_y, 0, "inputVarSize", e_y, 2);
  for (i = 0; i < 4; i++) {
    b_u[i] = moduleInstance->sysobj.ModulationPhaseOffset[i];
  }

  g_y = NULL;
  m = emlrtCreateCharArray(2, &iv2[0]);
  emlrtInitCharArrayR2013a((emlrtConstCTX)sp, 4, m, &b_u[0]);
  emlrtAssign(&g_y, m);
  emlrtSetFieldR2017b(b_y, 0, "ModulationPhaseOffset", g_y, 3);
  h_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.CustomPhaseOffset);
  emlrtAssign(&h_y, m);
  emlrtSetFieldR2017b(b_y, 0, "CustomPhaseOffset", h_y, 4);
  i_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.SamplesPerSymbol);
  emlrtAssign(&i_y, m);
  emlrtSetFieldR2017b(b_y, 0, "SamplesPerSymbol", i_y, 5);
  j_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.DampingFactor);
  emlrtAssign(&j_y, m);
  emlrtSetFieldR2017b(b_y, 0, "DampingFactor", j_y, 6);
  k_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.NormalizedLoopBandwidth);
  emlrtAssign(&k_y, m);
  emlrtSetFieldR2017b(b_y, 0, "NormalizedLoopBandwidth", k_y, 7);
  l_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.pProportionalGain);
  emlrtAssign(&l_y, m);
  emlrtSetFieldR2017b(b_y, 0, "pProportionalGain", l_y, 8);
  m_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.pIntegratorGain);
  emlrtAssign(&m_y, m);
  emlrtSetFieldR2017b(b_y, 0, "pIntegratorGain", m_y, 9);
  n_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.pDigitalSynthesizerGain);
  emlrtAssign(&n_y, m);
  emlrtSetFieldR2017b(b_y, 0, "pDigitalSynthesizerGain", n_y, 10);
  o_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.pPhase);
  emlrtAssign(&o_y, m);
  emlrtSetFieldR2017b(b_y, 0, "pPhase", o_y, 11);
  u_im = moduleInstance->sysobj.pPreviousSample.im;
  p_y = NULL;
  m = emlrtCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxCOMPLEX);
  r = (creal_T *)emlrtMxGetData(m);
  r->re = moduleInstance->sysobj.pPreviousSample.re;
  r->im = u_im;
  emlrtFreeImagIfZero(m);
  emlrtAssign(&p_y, m);
  emlrtSetFieldR2017b(b_y, 0, "pPreviousSample", p_y, 12);
  q_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.pActualPhaseOffset);
  emlrtAssign(&q_y, m);
  emlrtSetFieldR2017b(b_y, 0, "pActualPhaseOffset", q_y, 13);
  r_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.pLoopFilterState);
  emlrtAssign(&r_y, m);
  emlrtSetFieldR2017b(b_y, 0, "pLoopFilterState", r_y, 14);
  s_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.pIntegFilterState);
  emlrtAssign(&s_y, m);
  emlrtSetFieldR2017b(b_y, 0, "pIntegFilterState", s_y, 15);
  t_y = NULL;
  m = emlrtCreateDoubleScalar(moduleInstance->sysobj.pDDSPreviousInput);
  emlrtAssign(&t_y, m);
  emlrtSetFieldR2017b(b_y, 0, "pDDSPreviousInput", t_y, 16);
  emlrtSetCell(y, 0, b_y);
  u_y = NULL;
  m = emlrtCreateLogicalScalar(moduleInstance->sysobj_not_empty);
  emlrtAssign(&u_y, m);
  emlrtSetCell(y, 1, u_y);
  return y;
}

static const mxArray *cgxe_mdl_get_sim_state
  (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance)
{
  emlrtStack b_st = { NULL,            /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  const mxArray *st;
  b_st.tls = moduleInstance->emlrtRootTLSGlobal;
  st = NULL;
  emlrtAssign(&st, emlrt_marshallOut(moduleInstance, &b_st));
  return st;
}

static void emlrt_marshallIn(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const emlrtStack *sp, const mxArray *u)
{
  emlrtMsgIdentifier thisId;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  thisId.fIdentifier = "sysobj";
  b_emlrt_marshallIn(sp, emlrtAlias(emlrtGetCell((void *)sp, &thisId, u, 0)),
                     "sysobj", &moduleInstance->sysobj);
  thisId.fIdentifier = "sysobj_not_empty";
  moduleInstance->sysobj_not_empty = k_emlrt_marshallIn(sp, emlrtAlias
    (emlrtGetCell((void *)sp, &thisId, u, 1)), "sysobj_not_empty");
  emlrtDestroyArray(&u);
}

static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *nullptr,
  const char_T *identifier, comm_CarrierSynchronizer *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  c_emlrt_marshallIn(sp, emlrtAlias(nullptr), &thisId, y);
  emlrtDestroyArray(&nullptr);
}

static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, comm_CarrierSynchronizer *y)
{
  static const int32_T dims = 0;
  static const char_T *fieldNames[17] = { "isInitialized", "TunablePropsChanged",
    "inputVarSize", "ModulationPhaseOffset", "CustomPhaseOffset",
    "SamplesPerSymbol", "DampingFactor", "NormalizedLoopBandwidth",
    "pProportionalGain", "pIntegratorGain", "pDigitalSynthesizerGain", "pPhase",
    "pPreviousSample", "pActualPhaseOffset", "pLoopFilterState",
    "pIntegFilterState", "pDDSPreviousInput" };

  emlrtMsgIdentifier thisId;
  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckStructR2012b((emlrtConstCTX)sp, parentId, u, 17, (const char_T **)
    &fieldNames[0], 0U, (const void *)&dims);
  thisId.fIdentifier = "isInitialized";
  y->isInitialized = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 0, "isInitialized")), &thisId);
  thisId.fIdentifier = "TunablePropsChanged";
  y->TunablePropsChanged = e_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 1, "TunablePropsChanged")), &thisId);
  thisId.fIdentifier = "inputVarSize";
  f_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0,
    2, "inputVarSize")), &thisId, y->inputVarSize);
  thisId.fIdentifier = "ModulationPhaseOffset";
  h_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0,
    3, "ModulationPhaseOffset")), &thisId, y->ModulationPhaseOffset);
  thisId.fIdentifier = "CustomPhaseOffset";
  y->CustomPhaseOffset = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 4, "CustomPhaseOffset")), &thisId);
  thisId.fIdentifier = "SamplesPerSymbol";
  y->SamplesPerSymbol = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 5, "SamplesPerSymbol")), &thisId);
  thisId.fIdentifier = "DampingFactor";
  y->DampingFactor = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 6, "DampingFactor")), &thisId);
  thisId.fIdentifier = "NormalizedLoopBandwidth";
  y->NormalizedLoopBandwidth = i_emlrt_marshallIn(sp, emlrtAlias
    (emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0, 7, "NormalizedLoopBandwidth")),
    &thisId);
  thisId.fIdentifier = "pProportionalGain";
  y->pProportionalGain = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 8, "pProportionalGain")), &thisId);
  thisId.fIdentifier = "pIntegratorGain";
  y->pIntegratorGain = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 9, "pIntegratorGain")), &thisId);
  thisId.fIdentifier = "pDigitalSynthesizerGain";
  y->pDigitalSynthesizerGain = i_emlrt_marshallIn(sp, emlrtAlias
    (emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0, 10, "pDigitalSynthesizerGain")),
    &thisId);
  thisId.fIdentifier = "pPhase";
  y->pPhase = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 11, "pPhase")), &thisId);
  thisId.fIdentifier = "pPreviousSample";
  y->pPreviousSample = j_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 12, "pPreviousSample")), &thisId);
  thisId.fIdentifier = "pActualPhaseOffset";
  y->pActualPhaseOffset = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 13, "pActualPhaseOffset")), &thisId);
  thisId.fIdentifier = "pLoopFilterState";
  y->pLoopFilterState = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 14, "pLoopFilterState")), &thisId);
  thisId.fIdentifier = "pIntegFilterState";
  y->pIntegFilterState = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 15, "pIntegFilterState")), &thisId);
  thisId.fIdentifier = "pDDSPreviousInput";
  y->pDDSPreviousInput = i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b
    ((emlrtConstCTX)sp, u, 0, 16, "pDDSPreviousInput")), &thisId);
  emlrtDestroyArray(&u);
}

static int32_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  int32_T y;
  y = l_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static boolean_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId)
{
  boolean_T y;
  y = m_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, cell_wrap y[1])
{
  static const int32_T dims[1] = { 1 };

  static const char_T *fieldNames[1] = { "f1" };

  emlrtMsgIdentifier thisId;
  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckStructR2012b((emlrtConstCTX)sp, parentId, u, 1, (const char_T **)
    &fieldNames[0], 1U, (const void *)&dims[0]);
  thisId.fIdentifier = "f1";
  g_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0,
    0, "f1")), &thisId, y[0].f1);
  emlrtDestroyArray(&u);
}

static void g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, uint32_T y[8])
{
  n_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static void h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[4])
{
  o_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static real_T i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = p_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static creal_T j_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  creal_T y;
  y = q_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static boolean_T k_emlrt_marshallIn(const emlrtStack *sp, const mxArray *nullptr,
  const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  boolean_T y;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = e_emlrt_marshallIn(sp, emlrtAlias(nullptr), &thisId);
  emlrtDestroyArray(&nullptr);
  return y;
}

static void cgxe_mdl_set_sim_state(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance, const mxArray *st)
{
  emlrtStack b_st = { NULL,            /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  b_st.tls = moduleInstance->emlrtRootTLSGlobal;
  emlrt_marshallIn(moduleInstance, &b_st, emlrtAlias(st));
  emlrtDestroyArray(&st);
}

static const mxArray *message(const emlrtStack *sp, const mxArray *m1, const
  mxArray *m2, emlrtMCInfo *location)
{
  const mxArray *pArrays[2];
  const mxArray *m;
  pArrays[0] = m1;
  pArrays[1] = m2;
  return emlrtCallMATLABR2012b((emlrtConstCTX)sp, 1, &m, 2, &pArrays[0],
    "message", true, location);
}

static const mxArray *getString(const emlrtStack *sp, const mxArray *m1,
  emlrtMCInfo *location)
{
  const mxArray *m;
  const mxArray *pArray;
  pArray = m1;
  return emlrtCallMATLABR2012b((emlrtConstCTX)sp, 1, &m, 1, &pArray, "getString",
    true, location);
}

static void error(const emlrtStack *sp, const mxArray *m, const mxArray *m1,
                  emlrtMCInfo *location)
{
  const mxArray *pArrays[2];
  pArrays[0] = m;
  pArrays[1] = m1;
  emlrtCallMATLABR2012b((emlrtConstCTX)sp, 0, NULL, 2, &pArrays[0], "error",
                        true, location);
}

static const mxArray *b_message(const emlrtStack *sp, const mxArray *m1, const
  mxArray *m2, const mxArray *m3, const mxArray *m4, emlrtMCInfo *location)
{
  const mxArray *pArrays[4];
  const mxArray *m;
  pArrays[0] = m1;
  pArrays[1] = m2;
  pArrays[2] = m3;
  pArrays[3] = m4;
  return emlrtCallMATLABR2012b((emlrtConstCTX)sp, 1, &m, 4, &pArrays[0],
    "message", true, location);
}

static const mxArray *c_message(const emlrtStack *sp, const mxArray *m1,
  emlrtMCInfo *location)
{
  const mxArray *m;
  const mxArray *pArray;
  pArray = m1;
  return emlrtCallMATLABR2012b((emlrtConstCTX)sp, 1, &m, 1, &pArray, "message",
    true, location);
}

static int32_T l_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  int32_T ret;
  emlrtCheckBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "int32", false, 0U, (
    const void *)&dims);
  ret = *(int32_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static boolean_T m_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  boolean_T ret;
  emlrtCheckBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "logical", false, 0U, (
    const void *)&dims);
  ret = *emlrtMxGetLogicals(src);
  emlrtDestroyArray(&src);
  return ret;
}

static void n_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, uint32_T ret[8])
{
  static const int32_T dims[2] = { 1, 8 };

  int32_T i;
  uint32_T (*r)[8];
  emlrtCheckBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "uint32", false, 2U, (
    const void *)&dims[0]);
  r = (uint32_T (*)[8])emlrtMxGetData(src);
  for (i = 0; i < 8; i++) {
    ret[i] = (*r)[i];
  }

  emlrtDestroyArray(&src);
}

static void o_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[4])
{
  static const int32_T dims[2] = { 1, 4 };

  emlrtCheckBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "char", false, 2U, (
    const void *)&dims[0]);
  emlrtImportCharArrayR2015b((emlrtConstCTX)sp, src, &ret[0], 4);
  emlrtDestroyArray(&src);
}

static real_T p_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  real_T ret;
  emlrtCheckBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "double", false, 0U, (
    const void *)&dims);
  ret = *(real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static creal_T q_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  creal_T ret;
  emlrtCheckBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "double", true, 0U, (
    const void *)&dims);
  emlrtImportArrayR2015b((emlrtConstCTX)sp, src, &ret, 8, true);
  emlrtDestroyArray(&src);
  return ret;
}

static void init_simulink_io_address(InstanceStruct_gzVOtmwirXM3Cia4UeMwJ
  *moduleInstance)
{
  moduleInstance->emlrtRootTLSGlobal = (void *)cgxertGetEMLRTCtx
    (moduleInstance->S);
  moduleInstance->u0 = (creal_T *)cgxertGetInputPortSignal(moduleInstance->S, 0);
  moduleInstance->b_y0 = (creal_T *)cgxertGetOutputPortSignal(moduleInstance->S,
    0);
  moduleInstance->b_y1 = (real_T *)cgxertGetOutputPortSignal(moduleInstance->S,
    1);
}

/* CGXE Glue Code */
static void mdlOutputs_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S, int_T tid)
{
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)cgxertGetRuntimeInstance(S);
  cgxe_mdl_outputs(moduleInstance);
}

static void mdlInitialize_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S)
{
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)cgxertGetRuntimeInstance(S);
  cgxe_mdl_initialize(moduleInstance);
}

static void mdlUpdate_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S, int_T tid)
{
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)cgxertGetRuntimeInstance(S);
  cgxe_mdl_update(moduleInstance);
}

static void mdlDerivatives_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S)
{
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)cgxertGetRuntimeInstance(S);
  cgxe_mdl_derivative(moduleInstance);
}

static mxArray* getSimState_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S)
{
  mxArray* mxSS;
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)cgxertGetRuntimeInstance(S);
  mxSS = (mxArray *) cgxe_mdl_get_sim_state(moduleInstance);
  return mxSS;
}

static void setSimState_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S, const mxArray *ss)
{
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)cgxertGetRuntimeInstance(S);
  cgxe_mdl_set_sim_state(moduleInstance, emlrtAlias(ss));
}

static void mdlTerminate_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S)
{
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)cgxertGetRuntimeInstance(S);
  cgxe_mdl_terminate(moduleInstance);
  free((void *)moduleInstance);
}

static void mdlEnable_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S)
{
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)cgxertGetRuntimeInstance(S);
  cgxe_mdl_enable(moduleInstance);
}

static void mdlDisable_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S)
{
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)cgxertGetRuntimeInstance(S);
  cgxe_mdl_disable(moduleInstance);
}

static void mdlStart_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S)
{
  InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *moduleInstance =
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ *)calloc(1, sizeof
    (InstanceStruct_gzVOtmwirXM3Cia4UeMwJ));
  moduleInstance->S = S;
  cgxertSetRuntimeInstance(S, (void *)moduleInstance);
  ssSetmdlOutputs(S, mdlOutputs_gzVOtmwirXM3Cia4UeMwJ);
  ssSetmdlInitializeConditions(S, mdlInitialize_gzVOtmwirXM3Cia4UeMwJ);
  ssSetmdlUpdate(S, mdlUpdate_gzVOtmwirXM3Cia4UeMwJ);
  ssSetmdlDerivatives(S, mdlDerivatives_gzVOtmwirXM3Cia4UeMwJ);
  ssSetmdlTerminate(S, mdlTerminate_gzVOtmwirXM3Cia4UeMwJ);
  ssSetmdlEnable(S, mdlEnable_gzVOtmwirXM3Cia4UeMwJ);
  ssSetmdlDisable(S, mdlDisable_gzVOtmwirXM3Cia4UeMwJ);
  cgxe_mdl_start(moduleInstance);

  {
    uint_T options = ssGetOptions(S);
    options |= SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE;
    ssSetOptions(S, options);
  }
}

static void mdlProcessParameters_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S)
{
}

void method_dispatcher_gzVOtmwirXM3Cia4UeMwJ(SimStruct *S, int_T method, void
  *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_gzVOtmwirXM3Cia4UeMwJ(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_gzVOtmwirXM3Cia4UeMwJ(S);
    break;

   case SS_CALL_MDL_GET_SIM_STATE:
    *((mxArray**) data) = getSimState_gzVOtmwirXM3Cia4UeMwJ(S);
    break;

   case SS_CALL_MDL_SET_SIM_STATE:
    setSimState_gzVOtmwirXM3Cia4UeMwJ(S, (const mxArray *) data);
    break;

   default:
    /* Unhandled method */
    /*
       sf_mex_error_message("Stateflow Internal Error:\n"
       "Error calling method dispatcher for module: gzVOtmwirXM3Cia4UeMwJ.\n"
       "Can't handle method %d.\n", method);
     */
    break;
  }
}

mxArray *cgxe_gzVOtmwirXM3Cia4UeMwJ_BuildInfoUpdate(void)
{
  mxArray * mxBIArgs;
  mxArray * elem_1;
  mxArray * elem_2;
  mxArray * elem_3;
  mxArray * elem_4;
  mxArray * elem_5;
  mxArray * elem_6;
  mxArray * elem_7;
  mxArray * elem_8;
  mxArray * elem_9;
  mxArray * elem_10;
  mxArray * elem_11;
  mxArray * elem_12;
  mxArray * elem_13;
  mxArray * elem_14;
  mxArray * elem_15;
  mxArray * elem_16;
  mxArray * elem_17;
  mxArray * elem_18;
  mxArray * elem_19;
  mxArray * elem_20;
  mxArray * elem_21;
  mxArray * elem_22;
  mxArray * elem_23;
  mxBIArgs = mxCreateCellMatrix(1,3);
  elem_1 = mxCreateCellMatrix(1,6);
  elem_2 = mxCreateCellMatrix(0,0);
  mxSetCell(elem_1,0,elem_2);
  elem_3 = mxCreateCellMatrix(1,4);
  elem_4 = mxCreateString("addIncludeFiles");
  mxSetCell(elem_3,0,elem_4);
  elem_5 = mxCreateCellMatrix(1,3);
  elem_6 = mxCreateString("<string.h>");
  mxSetCell(elem_5,0,elem_6);
  elem_7 = mxCreateString("math.h");
  mxSetCell(elem_5,1,elem_7);
  elem_8 = mxCreateString("signLib.h");
  mxSetCell(elem_5,2,elem_8);
  mxSetCell(elem_3,1,elem_5);
  elem_9 = mxCreateCellMatrix(1,3);
  elem_10 = mxCreateString("");
  mxSetCell(elem_9,0,elem_10);
  elem_11 = mxCreateString("");
  mxSetCell(elem_9,1,elem_11);
  elem_12 = mxCreateString("");
  mxSetCell(elem_9,2,elem_12);
  mxSetCell(elem_3,2,elem_9);
  elem_13 = mxCreateCellMatrix(1,3);
  elem_14 = mxCreateString("");
  mxSetCell(elem_13,0,elem_14);
  elem_15 = mxCreateString("");
  mxSetCell(elem_13,1,elem_15);
  elem_16 = mxCreateString("");
  mxSetCell(elem_13,2,elem_16);
  mxSetCell(elem_3,3,elem_13);
  mxSetCell(elem_1,1,elem_3);
  elem_17 = mxCreateCellMatrix(0,0);
  mxSetCell(elem_1,2,elem_17);
  elem_18 = mxCreateCellMatrix(0,0);
  mxSetCell(elem_1,3,elem_18);
  elem_19 = mxCreateCellMatrix(0,0);
  mxSetCell(elem_1,4,elem_19);
  elem_20 = mxCreateCellMatrix(0,0);
  mxSetCell(elem_1,5,elem_20);
  mxSetCell(mxBIArgs,0,elem_1);
  elem_21 = mxCreateCellMatrix(1,1);
  elem_22 = mxCreateString("comm.internal.utilities.mathCore");
  mxSetCell(elem_21,0,elem_22);
  mxSetCell(mxBIArgs,1,elem_21);
  elem_23 = mxCreateCellMatrix(1,0);
  mxSetCell(mxBIArgs,2,elem_23);
  return mxBIArgs;
}

mxArray *cgxe_gzVOtmwirXM3Cia4UeMwJ_fallback_info(void)
{
  const char* fallbackInfoFields[] = { "fallbackType", "incompatiableSymbol" };

  mxArray* fallbackInfoStruct = mxCreateStructMatrix(1, 1, 2, fallbackInfoFields);
  mxArray* fallbackType = mxCreateString("thirdPartyLibs");
  mxArray* incompatibleSymbol = mxCreateString(
    "comm.internal.utilities.mathCore");
  mxSetFieldByNumber(fallbackInfoStruct, 0, 0, fallbackType);
  mxSetFieldByNumber(fallbackInfoStruct, 0, 1, incompatibleSymbol);
  return fallbackInfoStruct;
}
