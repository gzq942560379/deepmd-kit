#include "tensorflow/core/framework/op.h"
#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/framework/shape_inference.h"
#include <iostream>

using namespace tensorflow;
// using namespace std;

#ifdef HIGH_PREC
typedef double VALUETYPE;
#else
typedef float  VALUETYPE;
#endif

#ifdef HIGH_PREC
REGISTER_OP("MapAparam")
.Input("aparam: double")
.Input("nlist: int32")
.Input("natoms: int32")
.Attr("n_a_sel: int")
.Attr("n_r_sel: int")
.Output("output: double");
#else
REGISTER_OP("MapAparam")
.Input("aparam: float")
.Input("nlist: int32")
.Input("natoms: int32")
.Attr("n_a_sel: int")
.Attr("n_r_sel: int")
.Output("mapped: float");
#endif

using namespace tensorflow;

class MapAparamOp : public OpKernel {
 public:
  explicit MapAparamOp(OpKernelConstruction* context) : OpKernel(context) {
    OP_REQUIRES_OK(context, context->GetAttr("n_a_sel", &n_a_sel));
    OP_REQUIRES_OK(context, context->GetAttr("n_r_sel", &n_r_sel));
    n_a_shift = n_a_sel * 4;
  }

  void Compute(OpKernelContext* context) override {
    // Grab the input tensor
    int context_input_index = 0;
    const Tensor& aparam_tensor		= context->input(context_input_index++);
    const Tensor& nlist_tensor		= context->input(context_input_index++);
    const Tensor& natoms_tensor		= context->input(context_input_index++);

    // set size of the sample
    OP_REQUIRES (context, (aparam_tensor.shape().dims() == 2),		errors::InvalidArgument ("Dim of aparam should be 2"));
    OP_REQUIRES (context, (nlist_tensor.shape().dims() == 2),		errors::InvalidArgument ("Dim of nlist should be 2"));
    OP_REQUIRES (context, (natoms_tensor.shape().dims() == 1),		errors::InvalidArgument ("Dim of natoms should be 1"));

    OP_REQUIRES (context, (natoms_tensor.shape().dim_size(0) >= 3),	errors::InvalidArgument ("number of atoms should be larger than (or equal to) 3"));
    auto natoms	= natoms_tensor	.flat<int>();

    int nframes = aparam_tensor.shape().dim_size(0);
    int nloc = natoms(0);
    int nall = natoms(1);
    int nnei = nlist_tensor.shape().dim_size(1) / nloc;
    int numb_aparam = aparam_tensor.shape().dim_size(1) / nall;

    // check the sizes
    OP_REQUIRES (context, (nframes == nlist_tensor.shape().dim_size(0)),	errors::InvalidArgument ("number of samples should match"));
    OP_REQUIRES (context, (nnei == n_a_sel + n_r_sel),				errors::InvalidArgument ("number of neighbors should match"));

    // Create an output tensor
    TensorShape output_shape ;
    output_shape.AddDim (nframes);
    output_shape.AddDim (nloc * nnei * numb_aparam);
    Tensor* output_tensor = NULL;
    OP_REQUIRES_OK(context, context->allocate_output(0, output_shape, &output_tensor));
    
    // flat the tensors
    auto aparam = aparam_tensor.flat<VALUETYPE>();
    auto nlist = nlist_tensor.flat<int>();
    auto output = output_tensor->flat<VALUETYPE>();

    // loop over samples
#pragma omp parallel for 
    for (int kk = 0; kk < nframes; ++kk){
      int output_iter	= kk * nloc * nnei * numb_aparam;
      int aparam_iter	= kk * nall * numb_aparam;
      int nlist_iter	= kk * nloc * nnei;

      for (int ii = 0; ii < nloc; ++ii){
	int i_idx = ii;
	for (int dd = 0; dd < nnei * numb_aparam; ++dd) {
	  output(output_iter + i_idx * nnei * numb_aparam + dd) = 0.;
	}
      }

      // loop over loc atoms
      for (int ii = 0; ii < nloc; ++ii){
	int i_idx = ii;	
	// loop over neighbor atoms
	for (int jj = 0; jj < nnei; ++jj){
	  int j_idx = nlist (nlist_iter + i_idx * nnei + jj);
	  if (j_idx < 0) continue;
	  // loop over elements of aparam
	  for (int dd = 0; dd < numb_aparam; ++dd){
	    output(output_iter + ii * nnei * numb_aparam + jj * numb_aparam + dd) = aparam(aparam_iter + j_idx * numb_aparam + dd);
	  }
	}
      }
    }
  }
private:
  int n_r_sel, n_a_sel, n_a_shift;
};

REGISTER_KERNEL_BUILDER(Name("MapAparam").Device(DEVICE_CPU), MapAparamOp);



