### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 362714b0-75d8-11ed-22c0-49cceb161bb5
begin
	using PlutoUI
	using FFTW
	using HypertextLiteral
	θ = range(-π, stop=π, length=102)[1:end-1];
end;

# ╔═╡ c2256cfc-bade-4f40-9637-8593e7e37de2
@htl """
	Interact and Fourier Loaded
	<script src="https://cdn.jsdelivr.net/npm/interactjs@1.10.17/dist/interact.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fourier/fourier.min.js"></script>
"""

# ╔═╡ 524c1277-4650-477a-afba-8c89f2bb761c
md"""
Number of Linearly Interpolated Control Points: $(@bind num_lin_pts Slider(4:32, default=32, show_value=true))
"""

# ╔═╡ 348bc4d7-a3ae-4c7b-bc37-8c88c65329c1
begin
	θ_32 = range(-π, stop=π, length=num_lin_pts+1)[1:end-1]
	svg_x_32 = 100*cos.(θ_32) .+ 200
	svg_y_32 = 100*sin.(θ_32) .+ 200
	buf_32 = IOBuffer()
	for (x, y) in zip(svg_x_32, svg_y_32)
		print(buf_32, x ,", ", y, ",")
	end
	str_32 = String(take!(buf_32)[1:end-1])
	@htl("""
	<script src="https://cdn.jsdelivr.net/npm/interactjs@1.10.17/dist/interact.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fourier/fourier.min.js"></script>
	<h2>Current: 32 Linearly Interpolated Control Points</h2>
	<svg id="svg-edit-circle-32" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" value="3">
	
	<defs>
	    <circle id="point-handle32"
	        r="5" x="0" y="0"
	        stroke-width="2"
	        fill="#fff"
	        fill-opacity="0.4"
	        stroke="#fff"/>
	</defs>
	<circle cx="200" cy="200" r="10" />
	<polygon id="edit-circle-32"
	    stroke="#29e"
	    stroke-width="20"
	    stroke-linejoin="round"
	    fill="none"
	    points="$(str_32)"/>
	</svg>
		<script>
	console.log("SVG Script 32")
  const sns = 'http://www.w3.org/2000/svg'
  const xns = 'http://www.w3.org/1999/xlink'
  const root32 = document.getElementById('svg-edit-circle-32')
  const star32 = document.getElementById('edit-circle-32')
  let rootMatrix32
  const originalPoints32 = []
  let transformedPoints32 = []

  for (let i = 0, len = star32.points.numberOfItems; i < len; i += 1) {
    const handle = document.createElementNS(sns, 'use')
    const point = star32.points.getItem(i)
    const newPoint = root32.createSVGPoint()

    handle.setAttributeNS(xns, 'href', '#point-handle32')
    handle.setAttribute('class', 'point-handle32')

    handle.x.baseVal.value = newPoint.x = point.x
    handle.y.baseVal.value = newPoint.y = point.y

    handle.setAttribute('data-index', i)

    originalPoints32.push(newPoint)

    root32.appendChild(handle)
  }

  function applyTransforms32 (event) {
    rootMatrix32 = root32.getScreenCTM()

    transformedPoints32 = originalPoints32.map((point) => {
      return point.matrixTransform(rootMatrix32)
    })

    interact('.point-handle32').draggable({
      snap: {
        targets: transformedPoints32,
        range: 20 * Math.max(rootMatrix32.a, rootMatrix32.d),
      },
    })
  }

  interact(root32).on('mousedown', applyTransforms32).on('touchstart', applyTransforms32)

  interact('.point-handle32')
    .draggable({
      onstart: function (event) {
        root32.setAttribute('class', 'dragging')
      },
      onmove: function (event) {
	    if(rootMatrix32 == null) {
			return;
		}
	
        const i = event.target.getAttribute('data-index') | 0
        const point = star32.points.getItem(i)

		//Get angle and radius
		const theta = Math.atan2(point.y - 200, point.x - 200)

	    //unconstrained
        point.x += event.dx / rootMatrix32.a
        point.y += event.dy / rootMatrix32.d

	    //radially constrained
		const radial = Math.hypot(point.y - 200, point.x - 200)	    
	    point.x = radial * Math.cos(theta) + 200
	    point.y = radial * Math.sin(theta) + 200

        event.target.x.baseVal.value = point.x
        event.target.y.baseVal.value = point.y


      },
      onend: function (event) {
        root32.setAttribute('class', '')
      },
      /*snap: {
        targets: originalPoints32,
        range: 10,
        relativePoints: [{ x: 0.5, y: 0.5 }],
	},*/
      restrict: { restriction: document.rootElement },
    })
    .styleCursor(false)

  document.addEventListener('dragstart', (event) => {
    event.preventDefault()
  })
</script>
	""")
end

# ╔═╡ c815e8e1-ffb1-4b93-8f3e-a8fd0c149597
begin
	# flattened
	#svg_x = 100*cos.(θ) .* R_circle_cos.(θ) .+ 200
	#svg_y = 100*sin.(θ) .* R_circle_cos.(θ) .+ 200

	# circle
	svg_x = 100*cos.(θ) .+ 200
	svg_y = 100*sin.(θ) .+ 200
	buf = IOBuffer()
	for (x, y) in zip(svg_x, svg_y)
		print(buf, x ,", ", y, ",")
	end
	str = String(take!(buf)[1:end-1])
	num_cp = 7
	@bind mysvg @htl("""
	<h2>Fourier series interpolated</h2>
	<script src="https://cdn.jsdelivr.net/npm/interactjs@1.10.17/dist/interact.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fourier/fourier.min.js"></script>
	<svg id="svg-edit-demo" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" value="3">
	
	<defs>
	    <circle id="point-handle"
	        r="8" x="0" y="0"
	        stroke-width="3"
	        fill="#fff"
	        fill-opacity="0.4"
	        stroke="#fff"/>
	</defs>
	<circle cx="200" cy="200" r="10" />
	<polygon id="edit-star"
	    stroke="#29e"
	    stroke-width="20"
	    stroke-linejoin="round"
	    fill="none"
	    points="$(str)"/>
	</svg>
	<script>
	console.log("SVG Script")
  const sns = 'http://www.w3.org/2000/svg'
  const xns = 'http://www.w3.org/1999/xlink'
  const root = document.getElementById('svg-edit-demo')
  const star = document.getElementById('edit-star')
  let rootMatrix
  const originalPoints = []
  let transformedPoints = []

  let skip = Math.floor(101 / $num_cp)

  for (let i = 0, len = star.points.numberOfItems; i < len-skip; i += skip) {
    const handle = document.createElementNS(sns, 'use')
    const point = star.points.getItem(i)
    const newPoint = root.createSVGPoint()

    handle.setAttributeNS(xns, 'href', '#point-handle')
    handle.setAttribute('class', 'point-handle')

    handle.x.baseVal.value = newPoint.x = point.x
    handle.y.baseVal.value = newPoint.y = point.y

    handle.setAttribute('data-index', i)

    originalPoints.push(newPoint)

    root.appendChild(handle)
  }

  function applyTransforms (event) {
    rootMatrix = root.getScreenCTM()

    transformedPoints = originalPoints.map((point) => {
      return point.matrixTransform(rootMatrix)
    })

    interact('.point-handle').draggable({
      snap: {
        targets: transformedPoints,
        range: 20 * Math.max(rootMatrix.a, rootMatrix.d),
      },
    })
  }


  function updatePoints() {
    const star = document.querySelector("#edit-star")
	const controlPoints = document.querySelectorAll(".point-handle")
	const num_cp = $num_cp
	const num_pt = 100
	let x = new Array(num_cp)
	let y = new Array(num_cp)
    for(var i = 0; i < num_cp; i++) {
     x[i] = controlPoints[i].x.baseVal.value
     y[i] = controlPoints[i].y.baseVal.value
    }

	//let xhat = new Array(101)
	//let yhat = new Array(101)
	const [xhat, yhat] = fourier.dft(x ,y)
	
    let xlonghat = new Array(num_pt).fill(0.0)
    let ylonghat = new Array(num_pt).fill(0.0)

	const half_num_cp = Math.round(num_cp / 2)

	for(var i=0; i < half_num_cp; i++) {
		xlonghat[i] = xhat[i] * num_pt / num_cp
		ylonghat[i] = yhat[i] * num_pt / num_cp
	}

	for(var i=half_num_cp; i < num_cp; i++) {
		xlonghat[i-half_num_cp + num_pt-num_cp+1] = xhat[i] * num_pt / num_cp
		ylonghat[i-half_num_cp + num_pt-num_cp+1] = yhat[i] * num_pt / num_cp
	}

	
	/*
	xlonghat[0] = xhat[0] * num_pt / num_cp
	xlonghat[1] = xhat[1] * num_pt / num_cp
	xlonghat[2] = xhat[2] * num_pt / num_cp
	xlonghat[99] = xhat[3] * num_pt / num_cp
	xlonghat[100] = xhat[4] * num_pt / num_cp

	ylonghat[0] = yhat[0] * num_pt / num_cp
	ylonghat[1] = yhat[1] * num_pt / num_cp
	ylonghat[2] = yhat[2] * num_pt / num_cp
	ylonghat[99] = yhat[3] * num_pt / num_cp
	ylonghat[100] = yhat[4] * num_pt / num_cp
	*/

	//let xlong = new Array(101)
	//let ylong = new Array(101)
	const [xlong, ylong] = fourier.idft(xlonghat, ylonghat)
	
    for (var i=0; i < num_pt; i++) {
      star.points[i].x = xlong[i]
      star.points[i].y = ylong[i]
    }
	
  }

  function updatePointsRadial() {
    const star = document.querySelector("#edit-star")
	const controlPoints = document.querySelectorAll(".point-handle")
	const num_cp = $num_cp
	const num_pt = 100
	let x = new Array(num_cp)
	let y = new Array(num_cp)
	let r = new Array(num_cp)
    for(var i = 0; i < num_cp; i++) {
     x[i] = controlPoints[i].x.baseVal.value
     y[i] = controlPoints[i].y.baseVal.value
	 r[i] = Math.hypot(x[i]-200, y[i]-200)
	 //console.log(r[i])
    }
	

	let z = new Array(num_cp).fill(0.0)
	const [rhat, ihat] = fourier.dft(r, z)

	let rlonghat = new Array(num_pt).fill(0.0)
	let ilonghat = new Array(num_pt).fill(0.0)

	const half_num_cp = Math.round(num_cp / 2)
	console.log(half_num_cp)

	
	for(var i=0; i < half_num_cp; i++) {
		rlonghat[i] = rhat[i] * num_pt / num_cp
		ilonghat[i] = ihat[i] * num_pt / num_cp
	}

	for(var i=half_num_cp; i < num_cp; i++) {
		rlonghat[i - half_num_cp + num_pt - num_cp + half_num_cp+1] = rhat[i] * num_pt / num_cp
		ilonghat[i - half_num_cp+ num_pt - num_cp+ half_num_cp+1] = ihat[i] * num_pt / num_cp
		console.log(i -half_num_cp+ num_pt - num_cp+ half_num_cp+1)
	}
	

	/*
	rlonghat[0] = rhat[0] * num_pt / num_cp
	rlonghat[1] = rhat[1] * num_pt / num_cp
	rlonghat[2] = rhat[2] * num_pt / num_cp
	rlonghat[99] = rhat[3] * num_pt / num_cp
	rlonghat[100] = rhat[4] * num_pt / num_cp

	ilonghat[0] = ihat[0] * num_pt / num_cp
	ilonghat[1] = ihat[1] * num_pt / num_cp
	ilonghat[2] = ihat[2] * num_pt / num_cp
	ilonghat[99] = ihat[3] * num_pt / num_cp
	ilonghat[100] = ihat[4] * num_pt / num_cp
	*/

	const [rlong, _] = fourier.idft(rlonghat, ilonghat)
	
	//let xlong = new Array(num_pt)
	//let ylong = new Array(num_pt)

	let theta = -Math.PI

	for(var i=0; i < num_pt; i++) {
	   //console.log(rlong[i])
	   star.points[i].x = rlong[i] * Math.cos(theta) + 200
	   star.points[i].y = rlong[i] * Math.sin(theta) + 200
	   theta += 2 * Math.PI / (num_pt)
	}

	star.points[num_pt].x = star.points[0].x
	star.points[num_pt].y = star.points[0].y

	
  }

  interact(root).on('mousedown', applyTransforms).on('touchstart', applyTransforms)

  interact('.point-handle')
    .draggable({
      onstart: function (event) {
        root.setAttribute('class', 'dragging')
      },
      onmove: function (event) {
        const i = event.target.getAttribute('data-index') | 0
        const point = star.points.getItem(i)

		//Get angle and radius
		const theta = Math.atan2(point.y - 200, point.x - 200)

	    //unconstrained
        point.x += event.dx / rootMatrix.a
        point.y += event.dy / rootMatrix.d

	    //radially constrained
		const radial = Math.hypot(point.y - 200, point.x - 200)	    
	    point.x = radial * Math.cos(theta) + 200
	    point.y = radial * Math.sin(theta) + 200

        event.target.x.baseVal.value = point.x
        event.target.y.baseVal.value = point.y

		//updatePointsRadial()
	    //updatePoints()
      },
      onend: function (event) {
        root.setAttribute('class', '')
	    updatePointsRadial()
      },
      snap: {
        targets: originalPoints,
        range: 10,
        relativePoints: [{ x: 0.5, y: 0.5 }],
      },
      restrict: { restriction: document.rootElement },
    })
    .styleCursor(false)

  document.addEventListener('dragstart', (event) => {
    event.preventDefault()
  })
</script>
	""")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
FFTW = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
FFTW = "~1.5.0"
HypertextLiteral = "~0.9.4"
PlutoUI = "~0.7.49"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.1"
manifest_format = "2.0"
project_hash = "73087b533b6b88636ea8097ca247e4548d7282f8"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─362714b0-75d8-11ed-22c0-49cceb161bb5
# ╟─c2256cfc-bade-4f40-9637-8593e7e37de2
# ╟─524c1277-4650-477a-afba-8c89f2bb761c
# ╟─348bc4d7-a3ae-4c7b-bc37-8c88c65329c1
# ╠═c815e8e1-ffb1-4b93-8f3e-a8fd0c149597
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
