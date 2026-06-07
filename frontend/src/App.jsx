import { useEffect, useRef, useState } from 'react'

const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:5002'

export default function App() {
  const canvasRef = useRef(null)
  const boardRef = useRef(null)
  const cursorDotRef = useRef(null)
  const cursorOutlineRef = useRef(null)

  const [publicPosts, setPublicPosts] = useState([])
  const [promotionPosts, setPromotionPosts] = useState([])
  const [clubs, setClubs] = useState([])
  const [dropdownOpen, setDropdownOpen] = useState(false)

  useEffect(() => {
    fetch(`${API_BASE}/api/landing`)
      .then((res) => res.json())
      .then((data) => {
        setPublicPosts(data.latestPosts || [])
        setPromotionPosts(data.promotionPosts || [])
        setClubs(data.clubs || [])
      })
      .catch(() => {
        setPublicPosts([])
        setPromotionPosts([])
        setClubs([])
      })
  }, [])

  useEffect(() => {
    const onDocClick = (e) => {
      if (!e.target.closest('.dropdown')) setDropdownOpen(false)
    }
    document.addEventListener('click', onDocClick)
    return () => document.removeEventListener('click', onDocClick)
  }, [])

  useEffect(() => {
    
    const cursorDot = cursorDotRef.current
    const cursorOutline = cursorOutlineRef.current
    if (!cursorDot || !cursorOutline) return

    const onMouseMove = (e) => {
      const posX = e.clientX
      const posY = e.clientY
      cursorDot.style.left = `${posX}px`
      cursorDot.style.top = `${posY}px`
      cursorOutline.animate({ left: `${posX}px`, top: `${posY}px` }, { duration: 500, fill: 'forwards' })
    }

    window.addEventListener('mousemove', onMouseMove)
    return () => window.removeEventListener('mousemove', onMouseMove)
  }, [])

  useEffect(() => {
    const section = boardRef.current
    if (!section) return
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          section.classList.add('is-visible')
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.3 })
    observer.observe(section)
    return () => observer.disconnect()
  }, [])

  useEffect(() => {
    const setupScene = () => {
      if (!window.THREE || !canvasRef.current) return () => {}

      
      const THREE = window.THREE
      const container = canvasRef.current
      const cursorOutline = cursorOutlineRef.current

      const scene = new THREE.Scene()
      scene.fog = new THREE.FogExp2(0x050505, 0.04)

      const camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000)
      camera.position.z = 18
      camera.position.y = 2

      const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
      renderer.setSize(container.clientWidth, container.clientHeight)
      renderer.setPixelRatio(window.devicePixelRatio)
      container.appendChild(renderer.domElement)

      const particlesGeometry = new THREE.BufferGeometry()
      const particlesCount = 1000
      const posArray = new Float32Array(particlesCount * 3)
      for (let i = 0; i < particlesCount * 3; i += 1) posArray[i] = (Math.random() - 0.5) * 60
      particlesGeometry.setAttribute('position', new THREE.BufferAttribute(posArray, 3))
      const particlesMaterial = new THREE.PointsMaterial({
        size: 0.08,
        color: 0x00d4ff,
        transparent: true,
        opacity: 0.8,
        blending: THREE.AdditiveBlending,
      })
      const particlesMesh = new THREE.Points(particlesGeometry, particlesMaterial)
      scene.add(particlesMesh)

      const carouselGroup = new THREE.Group()
      scene.add(carouselGroup)

      const bannerCount = 8
      const radius = 13
      const bannerImages = [
        '/banner_image/CUVIC.png',
        '/banner_image/EMSYS.png',
        '/banner_image/G.DEV.FC.png',
        '/banner_image/NEST.NET.png',
        '/banner_image/NOVA.png',
        '/banner_image/pda.png',
        '/banner_image/SAMMaru.png',
        '/banner_image/TUX.png',
      ]
      const textureLoader = new THREE.TextureLoader()
      for (let i = 0; i < bannerCount; i += 1) {
        const angle = (i / bannerCount) * Math.PI * 2
        const geometry = new THREE.BoxGeometry(4.5, 7, 0.1)
        const texture = textureLoader.load(bannerImages[i])
        const material = new THREE.MeshBasicMaterial({
          map: texture,
          transparent: true,
          opacity: 0.9,
        })
        const mesh = new THREE.Mesh(geometry, material)

        const edges = new THREE.EdgesGeometry(geometry)
        const lineMaterial = new THREE.LineBasicMaterial({
          color: new THREE.Color().setHSL(i / bannerCount, 1, 0.6),
          linewidth: 2,
        })
        const line = new THREE.LineSegments(edges, lineMaterial)
        mesh.add(line)

        mesh.position.x = Math.cos(angle) * radius
        mesh.position.z = Math.sin(angle) * radius
        mesh.position.y = Math.sin(angle * 3) * 1.5
        mesh.rotation.y = -angle + Math.PI / 2

        carouselGroup.add(mesh)
      }

      let isDragging = false
      let previousMouseX = 0
      let previousMouseY = 0
      let targetRotationY = 0
      let targetRotationX = 0
      const autoRotateSpeed = 0.002

      const onPointerDown = (e) => {
        isDragging = true
        previousMouseX = e.clientX || e.touches?.[0]?.clientX || 0
        previousMouseY = e.clientY || e.touches?.[0]?.clientY || 0
        if (cursorOutline) {
          cursorOutline.style.transform = 'translate(-50%, -50%) scale(1.5)'
          cursorOutline.style.backgroundColor = 'rgba(0, 212, 255, 0.2)'
        }
      }

      const onPointerMove = (e) => {
        if (!isDragging) return
        const currentX = e.clientX || e.touches?.[0]?.clientX || 0
        const currentY = e.clientY || e.touches?.[0]?.clientY || 0
        const deltaX = currentX - previousMouseX
        const deltaY = currentY - previousMouseY
        targetRotationY += deltaX * 0.005
        targetRotationX += deltaY * 0.002
        targetRotationX = Math.max(-0.2, Math.min(0.2, targetRotationX))
        previousMouseX = currentX
        previousMouseY = currentY
      }

      const onPointerUp = () => {
        isDragging = false
        targetRotationX = 0
        if (cursorOutline) {
          cursorOutline.style.transform = 'translate(-50%, -50%) scale(1)'
          cursorOutline.style.backgroundColor = 'transparent'
        }
      }

      const onResize = () => {
        camera.aspect = container.clientWidth / container.clientHeight
        camera.updateProjectionMatrix()
        renderer.setSize(container.clientWidth, container.clientHeight)
      }

      container.addEventListener('mousedown', onPointerDown)
      window.addEventListener('mousemove', onPointerMove)
      window.addEventListener('mouseup', onPointerUp)
      container.addEventListener('touchstart', onPointerDown)
      window.addEventListener('touchmove', onPointerMove)
      window.addEventListener('touchend', onPointerUp)
      window.addEventListener('resize', onResize)

      const clock = new THREE.Clock()
      let animId = null
      const animate = () => {
        animId = requestAnimationFrame(animate)
        const elapsedTime = clock.getElapsedTime()
        if (!isDragging) targetRotationY += autoRotateSpeed
        carouselGroup.rotation.y += (targetRotationY - carouselGroup.rotation.y) * 0.1
        carouselGroup.rotation.x += (targetRotationX - carouselGroup.rotation.x) * 0.1
        particlesMesh.rotation.y = elapsedTime * 0.05
        particlesMesh.position.y = Math.sin(elapsedTime * 0.5) * 2
        carouselGroup.children.forEach((banner, idx) => {
          banner.position.y = Math.sin(elapsedTime * 2 + idx) * 0.5
        })
        renderer.render(scene, camera)
      }
      animate()

      return () => {
        if (animId) cancelAnimationFrame(animId)
        renderer.dispose()
        if (container.contains(renderer.domElement)) container.removeChild(renderer.domElement)
        container.removeEventListener('mousedown', onPointerDown)
        window.removeEventListener('mousemove', onPointerMove)
        window.removeEventListener('mouseup', onPointerUp)
        container.removeEventListener('touchstart', onPointerDown)
        window.removeEventListener('touchmove', onPointerMove)
        window.removeEventListener('touchend', onPointerUp)
        window.removeEventListener('resize', onResize)
      }
    }

    if (window.THREE) return setupScene()
    const script = document.createElement('script')
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js'
    script.onload = setupScene
    document.body.appendChild(script)
    return () => {
      if (script.parentNode) script.parentNode.removeChild(script)
    }
  }, [])

  return (
    <>
      <div className="cursor-dot" ref={cursorDotRef} />
      <div className="cursor-outline" ref={cursorOutlineRef} />

      <nav className="app-navbar" aria-label="주요 네비게이션">
        <a href="/" className="logo">ALL IN ONE</a>
        <div className="menu">
          <div className={`dropdown ${dropdownOpen ? 'open' : ''}`} id="board-dropdown">
            <a
              href="#"
              className="dropdown-toggle"
              id="board-toggle"
              onClick={(e) => {
                e.preventDefault()
                setDropdownOpen((prev) => !prev)
              }}
            >
              게시판 <span className="arrow">▼</span>
            </a>
            <div className="dropdown-menu">
              {clubs.length > 0 ? (
                clubs.map((club) => (
                  <a key={club.id} href="#">
                    {club.name}
                  </a>
                ))
              ) : (
                <a href="#">동아리 없음</a>
              )}
              <div className="dropdown-divider" />
              <a href="#">전체 게시판</a>
            </div>
          </div>

          <a href="#board-section">회의실</a>
          <a href={`${API_BASE}/auth/login`}>로그인</a>
          <a href={`${API_BASE}/auth/register`}>회원가입</a>
        </div>
      </nav>

      <div id="hero-section">
        <div id="ui-container">
          <h1><span>동</span><span>아</span><span>리</span> <span>통</span><span>합</span><span>게</span><span>시</span><span>판</span></h1>
          <p>화면을 드래그하여 동아리를 탐색해보세요</p>
        </div>
        <div id="canvas-container" ref={canvasRef} />
      </div>

      <div id="board-section" ref={boardRef}>
        <div className="board">
          <h2>공용게시판</h2>
          <ul className="board-list">
            {publicPosts.length > 0 ? (
              publicPosts.map((post) => (
                <li key={post.id}>
                  <a className="board-link" href="#">
                    <span className="board-title">{post.title}</span>
                    <span className="board-meta">
                      <span>{post.club_name}</span>
                      <span>{post.author_name}</span>
                      <span>{post.created_at}</span>
                    </span>
                  </a>
                </li>
              ))
            ) : (
              <li><span>공개 게시글이 없습니다.</span></li>
            )}
          </ul>
          <div style={{ marginTop: '18px' }}>
            <a href="#" style={{ color: '#00d4ff', textDecoration: 'none' }}>전체 공용게시판 보기</a>
          </div>
        </div>

        <div className="board">
          <h2>홍보게시판</h2>
          <ul className="board-list">
            {promotionPosts.length > 0 ? (
              promotionPosts.map((post) => (
                <li key={post.id}>
                  <a className="board-link" href="#">
                    <span className="board-title">{post.title}</span>
                    <span className="board-meta">
                      <span>{post.club_name}</span>
                      <span>{post.author_name}</span>
                      <span>{post.created_at}</span>
                    </span>
                  </a>
                </li>
              ))
            ) : (
              <li><span>홍보 게시글이 없습니다.</span></li>
            )}
          </ul>
        </div>
      </div>
    </>
  )
}
