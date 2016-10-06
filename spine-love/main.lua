-------------------------------------------------------------------------------
-- Spine Runtimes Software License
-- Version 2.3
-- 
-- Copyright (c) 2013-2015, Esoteric Software
-- All rights reserved.
-- 
-- You are granted a perpetual, non-exclusive, non-sublicensable and
-- non-transferable license to use, install, execute and perform the Spine
-- Runtimes Software (the "Software") and derivative works solely for personal
-- or internal use. Without the written permission of Esoteric Software (see
-- Section 2 of the Spine Software License Agreement), you may not (a) modify,
-- translate, adapt or otherwise create derivative works, improvements of the
-- Software or develop new applications using the Software or (b) remove,
-- delete, alter or obscure any trademarks or any copyright, trademark, patent
-- or other intellectual property or proprietary rights notices on or in the
-- Software, including any copy thereof. Redistributions in binary or source
-- form must include this license and terms.
-- 
-- THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
-- EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------

local spine = require "spine-love.spine-love"

local skeletons = {}
local activeSkeleton = 1

function loadSkeleton (jsonFile, atlasFile, animation, skin, scale, x, y)
  local loader = function (path) return love.graphics.newImage("data/" .. path) end
  local atlas = spine.TextureAtlas.new(spine.utils.readFile("data/" .. atlasFile .. ".atlas"), loader)
  
  local json = spine.SkeletonJson.new(spine.TextureAtlasAttachmentLoader.new(atlas))
  json.scale = scale
  local skeletonData = json:readSkeletonDataFile("data/" .. jsonFile .. ".json")
  local skeleton = spine.Skeleton.new(skeletonData)
  skeleton.x = x
  skeleton.y = y
  skeleton.flipX = false
  skeleton.flipY = true
  if skin then 
    skeleton:setSkin(skin)
  end
  skeleton:setToSetupPose()
  
  local stateData = spine.AnimationStateData.new(skeletonData)
  local state = spine.AnimationState.new(stateData)
  state:setAnimationByName(0, animation, true)
  
  state.onStart = function (trackIndex)
    print(trackIndex.." start: "..state:getCurrent(trackIndex).animation.name)
  end
  state.onEnd = function (trackIndex)
    print(trackIndex.." end: "..state:getCurrent(trackIndex).animation.name)
  end 
  state.onComplete = function (trackIndex, loopCount)
    print(trackIndex.." complete: "..state:getCurrent(trackIndex).animation.name..", "..loopCount)
  end
  state.onEvent = function (trackIndex, event)
    print(trackIndex.." event: "..state:getCurrent(trackIndex).animation.name..", "..event.data.name..", "..event.intValue..", "..event.floatValue..", '"..(event.stringValue or "").."'")
  end
  
  state:update(0.5)
  state:apply(skeleton)
  
  return { state = state, skeleton = skeleton }
end

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  -- table.insert(skeletons, loadSkeleton("test", "test", "animation", nil, 0.5, 400, 300))
  -- table.insert(skeletons, loadSkeleton("spineboy", "spineboy", "walk", nil, 0.5, 400, 500))
  -- table.insert(skeletons, loadSkeleton("raptor", "raptor", "walk", nil, 0.3, 400, 500))
  -- table.insert(skeletons, loadSkeleton("goblins-mesh", "goblins", "walk", "goblin", 1, 400, 500))
  -- table.insert(skeletons, loadSkeleton("tank", "tank", "drive", nil, 0.2, 600, 500))
  -- table.insert(skeletons, loadSkeleton("vine", "vine", "animation", nil, 0.3, 400, 500))
  table.insert(skeletons, loadSkeleton("stretchyman", "stretchyman", "sneak", nil, 0.3, 400, 500))
  skeletonRenderer = spine.SkeletonRenderer.new()
end

function love.update (delta)
	-- Update the state with the delta time, apply it, and update the world transforms.
  local state = skeletons[activeSkeleton].state
  local skeleton = skeletons[activeSkeleton].skeleton
	-- state:update(delta)
	-- state:apply(skeleton)
	skeleton:updateWorldTransform()
end

function love.draw ()
  love.graphics.setBackgroundColor(128, 128, 128, 255)
	love.graphics.setColor(255, 255, 255)
  local skeleton = skeletons[activeSkeleton].skeleton
  skeletonRenderer:draw(skeleton)
end

function love.mousepressed (x, y, button, istouch)
  activeSkeleton = activeSkeleton + 1
  if activeSkeleton > #skeletons then activeSkeleton = 1 end
end
