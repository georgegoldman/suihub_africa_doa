"use client";

import { useState } from "react";
import { useSignAndExecuteTransaction } from "@mysten/dapp-kit";
import { Transaction } from "@mysten/sui/transactions";

const PACKAGE_ID = "0x1"; 
const DAO_OBJECT_ID = "0x2"; 

export default function JoinDaoForm() {
  const [name, setName] = useState("");
  const [desc, setDesc] = useState("");
  const [imageUrl, setImageUrl] = useState("");
  const [userAddr, setUserAddr] = useState("");

  const { mutate: signAndExecute, isPending } = useSignAndExecuteTransaction({
    onSuccess: (res) => {
      console.log("Join DAO success:", res);
      alert("Joined DAO!");
    },
    onError: (err) => {
      console.error("Join DAO error:", err);
      alert("Error joining DAO.");
    },
  });

  function handleJoin() {
    const tx = new Transaction();

    tx.moveCall({
      target: `${PACKAGE_ID}::votting_dao::join_dao`,
      arguments: [
        tx.object(DAO_OBJECT_ID),
        tx.pure.string(name),
        tx.pure.string(desc),
        tx.pure.string(imageUrl),
        tx.pure.string(userAddr),
      ],
    });

    signAndExecute({
      transaction: tx,
    //   options: { showEffects: true },
    });
  }

  return (
    <div className="space-y-4 p-4 max-w-md mx-auto border rounded">
      <h2 className="text-xl font-bold">Join DAO</h2>

      <input
        className="w-full p-2 border rounded"
        placeholder="Your name"
        value={name}
        onChange={(e) => setName(e.target.value)}
      />

      <input
        className="w-full p-2 border rounded"
        placeholder="Your description"
        value={desc}
        onChange={(e) => setDesc(e.target.value)}
      />

      <input
        className="w-full p-2 border rounded"
        placeholder="Profile image URL"
        value={imageUrl}
        onChange={(e) => setImageUrl(e.target.value)}
      />

      <input
        className="w-full p-2 border rounded"
        placeholder="Your wallet address"
        value={userAddr}
        onChange={(e) => setUserAddr(e.target.value)}
      />

      <button
        onClick={handleJoin}
        disabled={isPending}
        className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
      >
        {isPending ? "Joining..." : "Join DAO"}
      </button>
    </div>
  );
}
