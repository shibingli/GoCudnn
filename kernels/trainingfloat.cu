extern "C" __global__
void adagradfloat(float *weights, //weights input and output
                  float *gsum, //storage
                  float *dw, //input and will have to set to zero
              //    float *loss1, //output
              //    float *loss2, //output
                  float rate, //input
            //      float decay1,//input
             //     float decay2,//input
             //     int batch, 
                  float eps){
                
 
    int section = blockIdx.x;
    int index = threadIdx.x;
    int cell = section*blockDim.x +index;
    gsum[cell]= gsum[cell]+(dw[cell]*dw[cell]);
    weights[cell]= -(rate*dw[cell])/(sqrtf(gsum[cell])+eps);
}


extern "C" __global__
void adamfloat(
          float *w,
          float *gsum,
          float *xsum,
          float *dw,
          float beta1,
          float beta2,
          float eps,
          float counter,
          ){
    
    int section = blockIdx.x;
    int index = threadIdx.x;
    int cell = section*blockDim.x +index;


    gsum[cell]=beta1*gsum[cell] +(1.0-beta1)*dw[cell];
    float gsumt = 0;
    gsumt = gsum[cell]/(1.0- _powf(beta1,counter));
    xsum[cell]= (beta2*xsum[cell])+((1.0 -beta2)*dw[cell]*dw[cell]);
    float xsumt =0;
    xsumt = xsum[cell]/(1.0 - _powf(beta2,counter));
    w[cell]+= -(eps*gsumt)/(sqrtf(xsumt)+eps)j;      
}


extern "C" __global__
void adadeltafloat(
                    float *weights, //weights input and output
                    float *gsum, //storage
                    float *xsum, //storage
                    float *dw, //input and will have to set to zero
               //     float *loss1, //output
                 //   float *loss2, //output
                    const float rate, //input
                  // const float decay1,//input
                   // const float decay2,//input from cpu
                    // const int batch, //input from cpu 
                    const float eps){



            int section = blockIdx.x;
            int index = threadIdx.x;
            int cell = section*blockDim.x +index;
/*
            if weights[cell]<0.0{
            decay1=-decay1;
            }*/
//decay2=weights[cell]*decay2;
//dw[cell]=(dw[cell]/(float)batch)+decay+decay2;
gsum[cell]= gsum[cell]+(dw[cell]*dw[cell]);
weights[cell]= -(rate*dw[cell])/(sqrtf(gsum[cell])+eps);
dw[cell]=0.0;
}

extern "C" __global__
void l1regularizationfloat(
    float *dw, //input and output
    float *w  //input
    int values, //number of values
    float *l1, //output
    float *l2, //output
    float batch, // should be an int but just send it as a float
    float decay1,
    const float decay2,
){
    int section = blockIdx.x;
    int index = threadIdx.x;
    int cell = section*blockDim.x+index;
    float decay = decay1;
    if (dw[cell]<0){
        decay=-decay;
    }
    atomicAdd(&l1,w[cell]*decay);
    dw[cell]= (dw[cell]/batch) +decay;
    
}  

extern "C" __global__
void l2regularizationfloat(
    float *dw, //input and output
    float *w  //input
    //int values, //number of values
    float *l1, //output
    float *l2, //output
    const float batch, // should be an int but just send it as a float
    const float decay1,
    const float decay2,

){
    int section = blockIdx.x;
    int index = threadIdx.x;
    int cell = section*blockDim.x+index;
    atomicAdd(&l2,(w[cell]*w[cell]*decay2)/2.0);
    dw[cell]= (dw[cell]/batch) + w[cell]*decay2;
    
}  

extern "C" __global__
void l1l2regularizationfloat(
    float *dw, //input and output
    float *w  //input needs to ba an array
   // int values, //number of values
    float *l1, //output set to zero
    float *l2, //output set to zero
   const float batch, // should be an int but just send it as a float
   const float decay1, //input
   const float decay2, //input
){
    int section = blockIdx.x;
    int index = threadIdx.x;
    int cell = section*blockDim.x+index;
    float decay = decay1;
    if (dw[cell]<0){
        decay=-decay;
    }

    atomicAdd(&l1,w[cell]*decay);
    atomicAdd(&l2,(w[cell]*w[cell]*decay2)/2.0);
    dw[cell]= (dw[cell]/batch) + (w[cell]*decay2) +decay1;
    
}  

