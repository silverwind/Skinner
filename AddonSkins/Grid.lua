if not Skinner:isAddonEnabled("Grid") then return end

function Skinner:Grid()

	if not Grid:IsActive() then return end

	GridLayout.db.profile.borderTexture = Skinner.db.profile.BdBorderTexture
	GridLayout.db.profile.BorderR = Skinner.db.profile.BackdropBorder.r
	GridLayout.db.profile.BorderG = Skinner.db.profile.BackdropBorder.g
	GridLayout.db.profile.BorderB = Skinner.db.profile.BackdropBorder.b
	GridLayout.db.profile.BorderA = Skinner.db.profile.BackdropBorder.a
	GridLayout.db.profile.BackgroundR = Skinner.db.profile.Backdrop.r
	GridLayout.db.profile.BackgroundG = Skinner.db.profile.Backdrop.g
	GridLayout.db.profile.BackgroundB = Skinner.db.profile.Backdrop.b
	GridLayout.db.profile.BackgroundA = Skinner.db.profile.Backdrop.a

end
