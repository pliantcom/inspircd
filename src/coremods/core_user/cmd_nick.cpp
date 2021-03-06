/*
 * InspIRCd -- Internet Relay Chat Daemon
 *
 *   Copyright (C) 2009-2010 Daniel De Graaf <danieldg@inspircd.org>
 *   Copyright (C) 2008 Craig Edwards <craigedwards@brainbox.cc>
 *   Copyright (C) 2008 Thomas Stagner <aquanight@inspircd.org>
 *   Copyright (C) 2007-2008 Robin Burchell <robin+git@viroteck.net>
 *
 * This file is part of InspIRCd.  InspIRCd is free software: you can
 * redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, version 2.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#include "inspircd.h"
#include "core_user.h"

CommandNick::CommandNick(Module* parent)
	: Command(parent, "NICK", 1, 1)
{
	works_before_reg = true;
	syntax = "<newnick>";
	Penalty = 0;
}

/** Handle nick changes from users.
 * NOTE: If you are used to ircds based on ircd2.8, and are looking
 * for the client introduction code in here, youre in the wrong place.
 * You need to look in the spanningtree module for this!
 */
CmdResult CommandNick::Handle (const std::vector<std::string>& parameters, User *user)
{
	std::string oldnick = user->nick;
	std::string newnick = parameters[0];

	// anything except the initial NICK gets a flood penalty
	if (user->registered == REG_ALL && IS_LOCAL(user))
		IS_LOCAL(user)->CommandFloodPenalty += 4000;

	if (newnick.empty())
	{
		user->WriteNumeric(ERR_ERRONEUSNICKNAME, "* :Erroneous Nickname");
		return CMD_FAILURE;
	}

	if (newnick == "0")
	{
		newnick = user->uuid;
	}
	else if (!ServerInstance->IsNick(newnick))
	{
		user->WriteNumeric(ERR_ERRONEUSNICKNAME, "%s :Erroneous Nickname", newnick.c_str());
		return CMD_FAILURE;
	}

	if (!user->ChangeNick(newnick, false))
		return CMD_FAILURE;

	if (user->registered < REG_NICKUSER)
	{
		user->registered = (user->registered | REG_NICK);
		if (user->registered == REG_NICKUSER)
		{
			/* user is registered now, bit 0 = USER command, bit 1 = sent a NICK command */
			ModResult MOD_RESULT;
			FIRST_MOD_RESULT(OnUserRegister, MOD_RESULT, (IS_LOCAL(user)));
			if (MOD_RESULT == MOD_RES_DENY)
				return CMD_FAILURE;

			// return early to not penalize new users
			return CMD_SUCCESS;
		}
	}

	return CMD_SUCCESS;
}
