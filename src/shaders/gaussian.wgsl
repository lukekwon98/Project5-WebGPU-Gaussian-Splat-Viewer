@group(0) @binding(0) var<uniform> camera: CameraUniforms;

@group(1) @binding(0) var<storage, read> gaussians_list: array<Gaussian>;

struct CameraUniforms {
    view: mat4x4<f32>,
    view_inv: mat4x4<f32>,
    proj: mat4x4<f32>,
    proj_inv: mat4x4<f32>,
    viewport: vec2<f32>,
    focal: vec2<f32>
};

struct Gaussian {
    pos_opacity: array<u32,2>,
    rot: array<u32,2>,
    scale: array<u32,2>
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    //TODO: information passed from vertex shader to fragment shader
};

// struct Splat {
//     //TODO: information defined in preprocess compute shader
// };

@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32, @builtin(instance_index) in_instance_index: u32) -> VertexOutput {
    //TODO: reconstruct 2D quad based on information from splat, pass 
   var out: VertexOutput;

    let gaussian = gaussians_list[in_instance_index];
    let a = unpack2x16float(gaussian.pos_opacity[0]);
    let b = unpack2x16float(gaussian.pos_opacity[1]);
    let pos = vec4<f32>(a.x, a.y, b.x, 1.);

    var ndcPos = camera.proj * camera.view * pos;
    ndcPos = ndcPos/ndcPos.w; //we do this now which is ok because the pipeline will divide by 1 anyway

    //triangle strip order (reuses the previous triangle's last to vertices)
    if(in_vertex_index == 0){
        out.position = vec4<f32>(ndcPos.x-0.005,ndcPos.y-0.005,ndcPos.z,1.);
    }
    else if(in_vertex_index == 1){
        out.position = vec4<f32>(ndcPos.x + 0.005,ndcPos.y-0.005,ndcPos.z,1.);
    }
    else if(in_vertex_index == 2){
        out.position = vec4<f32>(ndcPos.x - 0.005,ndcPos.y+0.005,ndcPos.z,1.);
    }
    else{
        out.position = vec4<f32>(ndcPos.x+0.005,ndcPos.y+0.005,ndcPos.z,1.);
    }

    return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return vec4<f32>(1.,0.,0.,1.);
}